{ pkgs, lib, config, inputs, ... }:

let
  prefs = import ../mixins/_preferences.nix { inherit inputs config lib pkgs; };

  # background = prefs.background;
  background = "#000000 solid_color";

  out_aw3418dw = "Dell Inc. Dell AW3418DW #ASPD8psOnhPd";
  out_aw2521h = "Dell Inc. Dell AW2521H #HLAYMxgwABDZ";
  out_carbon = "SDC 0x4152 Unknown";
  out_lgc165 = "Goldstar Company Ltd LG TV SSCR2 0x00000101";

  in_tp_carbon = "1739:52896:MSFT0001:00_06CB:CEA0_Touchpad";
  in_mouse_mxmaster3 = "1133:16514:Logitech_MX_Master_3";
  in_mouse_aerox3 = "4152:6200:SteelSeries_SteelSeries_Aerox_3_Wireless";
  in_touchscreen_carbon = "1267:11840:ELAN3915:00_04F3:2E40";

  _touchpad = {
    click_method = "clickfinger";
    tap = "enabled";
    dwt = "enabled";
    scroll_method = "two_finger";
    natural_scroll = "enabled";
    accel_profile = "adaptive";
    # pointer_accel = "1";
    # accel_profile = "flat";
    # pointer_accel = "0";
  };
  _mouse = {
    accel_profile = "flat";
    # pointer_accel = "0";
  };

  # silly gtk/gnome wayland schenanigans
  # TODO: see if this is necessary if we get HM to do it? or our own systemd user units?
  gsettings_auto =
    let
      gsettings = "${pkgs.glib}/bin/gsettings";
      gsettings_inner = pkgs.writeShellScript "gsettings-inner.sh" ''
        set -x
        set -eu
        expressions=""
        for pair in "$@"; do
          IFS=:; set -- $pair
          expressions="$expressions -e 's:^$2=(.*)$:${gsettings} set org.gnome.desktop.interface $1 \1:e'"
        done
        IFS=
        echo "" >/tmp/gsettings.log
        echo "$expressions" >/tmp/gsettings-expressions.log
        echo exec sed -E $expressions "''${XDG_CONFIG_HOME:-$HOME/.config}"/gtk-3.0/settings.ini &>>/tmp/gsettings.log
        eval exec sed -E $expressions "''${XDG_CONFIG_HOME:-$HOME/.config}"/gtk-3.0/settings.ini &>>/tmp/gsettings.log

        "${gsettings}" set org.gnome.desktop.interface "font-antialiasing" "grayscale"
      '';
    in
    pkgs.writeShellScript "gsettings-auto.sh" ''
      set -x
      set -euo pipefail

      ${gsettings_inner} \
        gtk-theme:gtk-theme-name \
        icon-theme:gtk-icon-theme-name \
        font-name:gtk-font-name \
        cursor-theme:gtk-cursor-theme-name \
        cursor-size:gtk-cursor-theme-size \
        gtk-xft-antialias:font-antialiasing \
        gtk-xft-hinting:font-hintstyle \
        gtk-xft-rgba:font-rgb-order \
          &>/tmp/gsettings-auto.log
    '';

  # change output scales incrementally w/ kb shortcuts
  outputScale = pkgs.writeShellScript "scale-wlr-outputs.sh" ''
    set -x
    set -euo pipefail
    delta=''${1}

    scale="$(swaymsg -t get_outputs | ${pkgs.jq}/bin/jq '.[] | select(.focused == true) | .scale')"
    printf -v scale "%.1f" "''${scale}"
    scale="$(echo "''${scale} ''${delta}" | ${pkgs.bc}/bin/bc)"

    swaymsg output "-" scale "''${scale}"
  '';
in

{
  imports = [
    ./gui-wayland.nix
    ./waybar.nix
  ];
  config = {
    nixpkgs.overlays = [
      inputs.nixpkgs-wayland.overlay
    ];

    xdg.portal.enable = true;
    xdg.portal.extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      (xdg-desktop-portal-gtk.override {
        buildPortalsInGnome = false;
      })
    ];

    #
    #
    # mixins/sway.nix:
    security.pam.services.swaylock = { };

    home-manager.users.cole = { pkgs, config, ... }@hm:
      let
        swaymsg = "${hm.config.wayland.windowManager.sway.package}/bin/swaymsg";
      in
      {
        home.sessionVariables = {
          XDG_CURRENT_DESKTOP = "sway";
        };

        wayland.windowManager.sway = {
          enable = true;
          package = pkgs.sway.override { sway-unwrapped = inputs.nixpkgs-wayland.packages.${pkgs.hostPlatform.system}.sway-unwrapped; };
          systemdIntegration = true; # beta
          wrapperFeatures = {
            base = false; # this should be the default (dbus activation, not sure where XDG_CURRENT_DESKTOP comes from)
            gtk = true; # I think this is also the default...
          };
          xwayland = true;
          extraConfig = (lib.optionalString (prefs.cursor != null) ''
            seat seat0 xcursor_theme "${prefs.cursor.name}" ${builtins.toString prefs.cursorSize}
          '');
          config = rec {
            modifier = "Mod4";
            terminal = prefs.default_term;
            fonts = prefs.swayfonts;
            focus.followMouse = "always";
            colors =
              let
                # from gruvbox image:
                red = "#cc241d";
                pink = "#d3869b";
                blue = "#458588";
                green = "#b8bb26";
                yellow = "#d79921";
                orange = "#fe8019";
                # bgcolor = "#2c2c2c";
                bgcolor = "#000000";
                _f = red;
              in
              {
                "focused" = { border = _f; background = _f; text = "#ffffff"; indicator = "#ffffff"; childBorder = _f; };
                "unfocused" = { border = bgcolor; background = bgcolor; text = "#888888"; indicator = "#ffffff"; childBorder = bgcolor; };
              };
            gaps = { inner = 2; outer = 2; };
            window.border = 4;
            window.titlebar = false;
            window.commands = [
              { criteria = { app_id = "mpv"; }; command = "sticky enable"; }
              { criteria = { app_id = "mpv"; }; command = "floating enable"; }
              { criteria = { title = "^(.*) Indicator"; }; command = "floating enable"; }
              { criteria = { app_id = "floatmeplz"; }; command = "floating enable"; }
              { criteria = { app_id = "prs-gtk3-copy"; }; command = "floating enable"; }
              { criteria = { app_id = "gcr-prompter"; }; command = "border pixel 400"; }
            ];
            startup = [
              { always = true; command = "${gsettings_auto}"; }
            ];
            input = {
              "${in_tp_carbon}" = _touchpad;
              "${in_mouse_mxmaster3}" = _mouse;
              "${in_mouse_aerox3}" = _mouse;
              "${in_touchscreen_carbon}" = { events = "disabled"; };
            };
            output = {
              "${out_aw3418dw}" = {
                mode = "3440x1440@120Hz";
                pos = "0 0";
                subpixel = "rgb";
                scale = "1.0";
                adaptive_sync = "on";
              };
              "${out_aw2521h}" = {
                mode = "1920x1080@340Hz";
                pos = "0 0";
                subpixel = "rgb";
                scale = "1.0";
                adaptive_sync = "on";
              };
              "${out_carbon}" = {
                mode = "2880x1800@90Hz";
                pos = "3440 0";
                subpixel = "rgb";
                scale = "1.8";
                adaptive_sync = "on";
              };
              "${out_lgc165}" = {
                disable = "";
              };
              "*" = {
                background = background;
              };
            };
            bars = [ ];
            keybindings = {
              "${modifier}+Return" = "exec ${terminal}";
              "${modifier}+Shift+q" = "kill";

              "${modifier}+Escape" = "exec ${prefs.default_launcher}";
              "${modifier}+Ctrl+Alt+Delete" = "exec ${swaymsg} exit";
              "${modifier}+Ctrl+Alt+Insert" = "exec ${swaymsg} reload";

              "${modifier}+h" = "focus left";
              "${modifier}+j" = "focus down";
              "${modifier}+k" = "focus up";
              "${modifier}+l" = "focus right";

              "${modifier}+Tab" = "${pkgs.sway}/bin/swaymsg seat '*' pointer_constraint escape";

              "${modifier}+Shift+h" = "move left";
              "${modifier}+Shift+j" = "move down";
              "${modifier}+Shift+k" = "move up";
              "${modifier}+Shift+l" = "move right";

              "${modifier}+Prior" = "workspace prev";
              "${modifier}+Next" = "workspace next";

              "${modifier}+b" = "splith";
              "${modifier}+v" = "splitv";
              "${modifier}+f" = "fullscreen toggle";
              "${modifier}+a" = "focus parent";

              "${modifier}+s" = "layout stacking";
              "${modifier}+w" = "layout tabbed";
              "${modifier}+e" = "layout toggle split";

              "${modifier}+Shift+space" = "floating toggle";
              "${modifier}+Shift+Alt+space" = "sticky toggle";
              "${modifier}+space" = "focus mode_toggle";

              "${modifier}+1" = "workspace number 1";
              "${modifier}+2" = "workspace number 2";
              "${modifier}+3" = "workspace number 3";
              "${modifier}+4" = "workspace number 4";
              "${modifier}+5" = "workspace number 5";
              "${modifier}+6" = "workspace number 6";
              "${modifier}+7" = "workspace number 7";
              "${modifier}+8" = "workspace number 8";
              "${modifier}+9" = "workspace number 9";

              "${modifier}+Shift+1" = "move container to workspace number 1";
              "${modifier}+Shift+2" = "move container to workspace number 2";
              "${modifier}+Shift+3" = "move container to workspace number 3";
              "${modifier}+Shift+4" = "move container to workspace number 4";
              "${modifier}+Shift+5" = "move container to workspace number 5";
              "${modifier}+Shift+6" = "move container to workspace number 6";
              "${modifier}+Shift+7" = "move container to workspace number 7";
              "${modifier}+Shift+8" = "move container to workspace number 8";
              "${modifier}+Shift+9" = "move container to workspace number 9";

              "${modifier}+Shift+minus" = "move scratchpad";
              "${modifier}+minus" = "scratchpad show";

              "--locked ${modifier}+Ctrl+Alt+Home" = "output * enable";
              "--locked ${modifier}+Ctrl+Alt+End" = "output -- disable";
              "${modifier}+Ctrl+Alt+equal" = "exec ${outputScale} +.1";
              "${modifier}+Ctrl+Alt+minus" = "exec ${outputScale} -.1";

              "${modifier}+Print" = ''exec ${pkgs.grim}/bin/grim \"''${HOME}/screenshot-$(date '+%s').png\"'';
              "${modifier}+Shift+Print" = ''exec ${pkgs.grim}/bin/grim  -g \"$(slurp)\" \"''${HOME}/screenshot-$(date '+%s').png\"'';

              "${modifier}+Ctrl+Alt+Up" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set +10";
              "${modifier}+Ctrl+Alt+Down" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 10-";
              "${modifier}+Ctrl+Alt+Prior" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set +100";
              "${modifier}+Ctrl+Alt+Next" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 100-";
              "${modifier}+Ctrl+Alt+Left" = "exec ${pkgs.pulsemixer}/bin/pulsemixer --change-volume -2";
              "${modifier}+Ctrl+Alt+Right" = "exec ${pkgs.pulsemixer}/bin/pulsemixer --change-volume +2";
            };
          };
        };
      };
  };
}
