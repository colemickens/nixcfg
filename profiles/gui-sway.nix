{ pkgs, lib, config, inputs, ... }:

let

  prefs = import ../mixins/_preferences.nix { inherit inputs config lib pkgs; };

  out_zeph = "Thermotrex Corporation TL140ADXP01 Unknown";
  out_aw34 = "Dell Inc. Dell AW3418DW #ASPD8psOnhPd";
  out_aw25 = "Dell Inc. Dell AW2521H #HLAYMxgwABDZ";

  in_tp_zeph = "1267:12699:ASUE120A:00_04F3:319B_Touchpad";
  in_mouse_aerox3 = "4152:6200:SteelSeries_SteelSeries_Aerox_3_Wireless";
  in_mouse_gpro = "1133:16505:Logitech_G_Pro";

  _touchpad = {
    click_method = "clickfinger";
    tap = "enabled";
    dwt = "enabled";
    scroll_method = "two_finger";
    natural_scroll = "enabled";
    accel_profile = "adaptive";
    pointer_accel = "0.5";
    # accel_profile = "flat";
    # pointer_accel = "0";
  };
  _mouse = {
    accel_profile = "flat";
  };

  screenshot = pkgs.writeShellScript "screenshot.sh" ''
    mkdir -p "''${HOME}/screenshots"
    ${pkgs.grim}/bin/grim "''${HOME}/screenshots/screenshot-$(date '+%s').png"
  '';
  screenshotArea = pkgs.writeShellScript "screenshot-area.sh" ''
    mkdir -p "''${HOME}/screenshots"
    ${pkgs.grim}/bin/grim -g "$(slurp)" "''${HOME}/screenshots/screenshot-$(date '+%s').png"
  '';

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
    # ../mixins/i3status-rust.nix
    ../mixins/mako.nix
    ../mixins/waybar.nix
  ];
  config = {
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
      ];
      config = {
        common = {
          default = [ "gtk" ];
        };
        sway = {
          default = [ "gtk" ];
          "org.freedesktop.impl.portal.Screencast" = [ "wlr" ];
          "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
        };
      };
      #   extraPortal = with pkgs; [
      #     xdg-desktop-portal-wlr
      #     (xdg-desktop-portal-gtk.override {
      #       buildPortalsInGnome = false;
      #     })
      #   ];
    };

    nixpkgs.overlays = [
      (final: prev:
        let
          nwpkgs = inputs.nixpkgs-wayland.outputs.packages.${pkgs.stdenv.hostPlatform.system};
        in
        {
          inherit (nwpkgs)
            sway-unwrapped
            swaylock
            xdg-desktop-portal-wlr
            ;
        })
    ];

    security.pam.services.swaylock = { };
    security.pam.services.waylock = { }; # TODO: what is this actually doing? match binary name?

    home-manager.users.cole = { pkgs, config, ... }@hm:
      let
        swaymsg = "${hm.config.wayland.windowManager.sway.package}/bin/swaymsg";
      in
      {
        home.packages = with pkgs; [ waylock ];

        home.sessionVariables = {
          WLR_RENDERER = "vulkan";
          XDG_CURRENT_DESKTOP = "sway";
        };

        programs.swaylock = {
          enable = true;
          settings = {
            inherit (prefs.background) image scaling color;
          };
        };

        services.swayidle = {
          enable = true;
          events = [
            { event = "before-sleep"; command = "${pkgs.swaylock}/bin/swaylock -f"; }
            { event = "lock"; command = "${pkgs.swaylock}/bin/swaylock -f"; }
          ];
          timeouts = [
            { timeout = 360; command = "${pkgs.swaylock}/bin/swaylock -f"; }
          ];
        };

        wayland.windowManager.sway = {
          enable = true;
          systemd = {
            enable = true; # beta
          };
          wrapperFeatures = {
            base = false; # this should be the default (dbus activation, not sure where XDG_CURRENT_DESKTOP comes from)
            gtk = true; # I think this is also the default...
          };
          # xwayland = false;
          xwayland = true;
          extraConfig = (lib.optionalString (prefs.cursor != null) ''
            seat seat0 xcursor_theme "${prefs.cursor.name}" ${builtins.toString prefs.cursorSize}
          '');
          config = rec {
            modifier = "Mod4";
            terminal = prefs.default_term;
            fonts = prefs.swayfonts;
            focus.followMouse = "always";
            # colors = {
            #   "focused" = { border = borderActive; background = borderActive; text = "#ffffff"; indicator = "#ffffff"; childBorder = borderActive; };
            #   "unfocused" = { border = borderInactive; background = borderInactive; text = "#888888"; indicator = "#ffffff"; childBorder = borderInactive; };
            # };
            # gaps = { inner = 2; outer = 0; };
            window.hideEdgeBorders = "smart";
            window.border = 4;
            window.titlebar = true;
            window.commands = [
              # { criteria = { app_id = "mpv"; }; command = "sticky enable"; }
              # { criteria = { app_id = "mpv"; }; command = "floating enable"; }
              { criteria = { title = "^(.*) Indicator"; }; command = "floating enable"; }
            ];
            startup = [
              { always = true; command = "${gsettings_auto}"; }
              { always = true; command = "${pkgs.asusctl}/bin/rog-control-center"; }
            ];
            input = {
              "${in_tp_zeph}" = _touchpad;
              "${in_mouse_aerox3}" = _mouse;
              "${in_mouse_gpro}" = _mouse;
            };
            output = {
              "*" = let b = prefs.background; in {
                background = "${b.image} ${b.scaling} #${b.color}";
              };
              # "${out_aw34}" = {
              #   scale = "1.0";
              #   mode = "3440x1440@120Hz";
              #   adaptive_sync = "enable";
              #   subpixel = "rgb";
              #   position = "1920 0";
              # };
              # "${out_aw25}" = {
              #   scale = "1.0";
              #   mode = "1920x1080@240Hz";
              #   adaptive_sync = "enable";
              #   subpixel = "rgb";
              #   render_bit_depth = "10";
              #   position = "0 0";
              # };
              "${out_zeph}" = {
                scale = "1.6";
                mode = "2560x1600@120Hz";
                adaptive_sync = "enable";
                # position = "5360 0";
                position = "0 0";
                subpixel = "rgb";
              };
            };
            # bars = [
            #   {
            #     statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-default.toml";
            #     position = "top";
            #   }
            # ];
            bars = [ ];
            assigns = {
              "9" = [
                { class = "^steam_app_"; }
                { app_id = "^Steam$"; }
                # { class = "^steam$"; } # untested
                { class = "^steam$"; }
                { class = "^Steam$"; }
              ];
            };
            keybindings = {
              "${modifier}+Return" = "exec ${prefs.default_term}";
              "${modifier}+Shift+q" = "kill";

              "${modifier}+Delete" = "exec ${pkgs.swaylock}/bin/swaylock";

              "${modifier}+F1" = "exec ${pkgs.systemd}/bin/systemctl --user restart waybar";
              "${modifier}+F2" = "exec ${pkgs.systemd}/bin/systemctl --user stop waybar";

              "${modifier}+Escape" = "exec ${pkgs.sirula}/bin/sirula";
              "${modifier}+Ctrl+Alt+Delete" = "exec ${swaymsg} exit";
              "Ctrl+Alt+Delete" = "exec ${swaymsg} exit";
              "${modifier}+Ctrl+Alt+Insert" = "exec ${swaymsg} reload";

              "XF86AudioRaiseVolume" = "exec ${pkgs.pulsemixer}/bin/pulsemixer --change-volume +2";
              "XF86AudioLowerVolume" = "exec ${pkgs.pulsemixer}/bin/pulsemixer --change-volume -2";
              "XF86AudioMute" = "exec ${pkgs.pulsemixer}/bin/pulsemixer --toggle-mute";
              "XF86Launch4" = "exec ${pkgs.asusctl}/bin/asusctl profile -n";

              "${modifier}+h" = "focus left";
              "${modifier}+j" = "focus down";
              "${modifier}+k" = "focus up";
              "${modifier}+l" = "focus right";

              "${modifier}+Home" = "${pkgs.sway}/bin/swaymsg seat '*' pointer_constraint escape";

              "${modifier}+Tab" = "workspace next";
              "${modifier}+Shift+Tab" = "workspace prev";

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

              # "${modifier}+F12" = ''exec ${pkgs.grim}/bin/grim \"''${HOME}/screenshots/screenshot-$(date '+%s').png\"'';
              # "${modifier}+Shift+F12" = ''exec ${pkgs.grim}/bin/grim  -g \"$(slurp)\" \"''${HOME}/screenshots/screenshot-$(date '+%s').png\"'';
              "${modifier}+F12" = "exec ${screenshot}";
              "${modifier}+Shift+F12" = "exec ${screenshotArea}";

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
