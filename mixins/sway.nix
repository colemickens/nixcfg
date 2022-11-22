{ config, lib, pkgs, inputs, ... }:

let
  prefs = import ./_preferences.nix { inherit inputs config lib pkgs; };

  background = prefs.background;

  out_aw3418dw = "Dell Inc. Dell AW3418DW #ASPD8psOnhPd";
  out_aw2521h = "Dell Inc. Dell AW2521H #HLAYMxgwABDZ";
  out_raisin = "Unknown 0x1402 0x00000000";
  out_carbon = "SDC 0x4152 Unknown";
  out_lgc165 = "Goldstar Company Ltd LG TV SSCR2 0x00000101";
  out_rpi4_lgc165 = "LG Electronics LG TV SSCR2 0x00000101";

  in_tp_pinebook = "9610:30:HAILUCK_CO.,LTD_USB_KEYBOARD_Touchpad";
  in_tp_carbon = "1739:52896:MSFT0001:00_06CB:CEA0_Touchpad";
  in_tp_raisin = "1739:52804:MSFT0001:00_06CB:CE44_Touchpad";
  in_tp_trackpoint_ii = "6127:24814:Lenovo_TrackPoint_Keyboard_II";
  in_mouse_logi = "1133:16505:Logitech_G_Pro";
  in_kb_porty = "1118:1957:Microsoft_Microsoft___Nano_Transceiver_v2.1_Consumer_Control";
  in_kb_carbon = "1:1:AT_Translated_Set_2_keyboard";
  in_kb_raisin = "1:1:AT_Translated_Set_2_keyboard";

  cmd_pass = "${prefs.default_term} --class floatmeplz -e 'gopass-clip'";
  cmd_totp = "${prefs.default_term} --class floatmeplz -e 'gopass-totp'";
  cmd_empi = "${pkgs.wezterm}/bin/wezterm start --class floatmeplz 'emoji-pick'";

  statusCommand = "${pkgs.waybar}/bin/waybar";

  _keyboard = {
    xkb_layout = "us";
    xkb_options = "shift:both_capslock,caps:super";
  };
  _touchpad = {
    click_method = "clickfinger";
    tap = "enabled";
    dwt = "enabled";
    scroll_method = "two_finger";
    natural_scroll = "enabled";
    accel_profile = "adaptive";
    pointer_accel = "1";
  };
  _mouse = {
    accel_profile = "adaptive";
    pointer_accel = ".1";
  };
  _hostinputs = {
    porty = {
      "${in_kb_porty}" = _keyboard;
      "${in_mouse_logi}" = _mouse;
    };
    pinebook = {
      "${in_tp_pinebook}" = _touchpad;
    };
    carbon = {
      "${in_tp_carbon}" = _touchpad;
      "${in_kb_carbon}" = _keyboard;
    };
    raisin = {
      "${in_tp_raisin}" = _touchpad;
      "${in_kb_raisin}" = _keyboard;
    };
  };
  hostinputs = let hn = config.networking.hostName; in
    if !builtins.hasAttr hn _hostinputs
    then { "input:keyboard" = _keyboard; }
    else _hostinputs.${hn};

  # silly gtk/gnome wayland schenanigans
  # TODO: see if this is necessary if we get HM to do it? or our own systemd user units?
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
  #gsettings_auto = pkgs.writeShellScript "gsettings-true.sh" "true";
  gsettings_auto = pkgs.writeShellScript "gsettings-auto.sh" ''
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
  config = {
    security.pam.services.swaylock = { };

    home-manager.users.cole = { pkgs, config, ... }@hm:
      let
        # swaylock = "${hm.config.programs.swaylock.package}/bin/swaylock";
        swaylock = "${pkgs.swaylock-effects}/bin/swaylock";
        swaymsg = "${hm.config.wayland.windowManager.sway.package}/bin/swaymsg";
      in
      {
        # block auto-sway reload, Sway crashes... ... but now  we work around it by doing kbmods per dev
        #xdg.configFile."sway/config".onChange = lib.mkForce "";

        programs.swaylock = {
          # enable = true;
          # package = pkgs.swaylock-effects;
          settings = {
            daemonize = true;
            show-failed-attempts = true;
            ignore-empty-password = true;

            grace = 16;
            fade = 15; # swaylock-effects only

            color = "000000";
            # font-size = 24;
            # indicator-idle-visible = false;
            # indicator-radius = 100;
            # line-color = "ffffff";
          };
        };
        services.swayidle =
          let
            pgrep = "${pkgs.procps}/bin/pgrep";
            dpms_check = s: pkgs.writeShellScript "dpms_check_${s}" ''
              set -x
              if ${pgrep} swaylock; then ${swaymsg} 'output * dpms ${s}'; fi
            '';
            dpms_set = s: pkgs.writeShellScript "dpms_set_${s}" ''
              set -x
              "${swaymsg}" 'output * dpms ${s}'
            '';
            fadelock = pkgs.writeShellScript "fadelock.sh" ''
              set -x
              exec "${swaylock}"
            '';
          in
          {
            enable = false;
            systemdTarget = "graphical-session.target";
            timeouts = [
              # auto-lock after 30 seconds
              { timeout = 30; command = fadelock.outPath; }
              # after any event, after 60 seconds, run dpms_off
              # { timeout = 60; command = "${dpms_set "off"}"; resumeCommand = "${dpms_set "on"}"; }
              # triggered after event changes, after 60 seconds after event, check to see if we should dpms_off
              # { timeout = 60; command = "${dpms_check "off"}"; resumeCommand = "${dpms_check "on"}"; }
            ];
            events = [
              { event = "before-sleep"; command = fadelock.outPath; }
            ];
            extraArgs = [
              "idlehint 30"
            ];
          };
        wayland.windowManager.sway = {
          enable = true;
          systemdIntegration = true; # beta
          wrapperFeatures = {
            base = false; # this should be the default (dbus activation, not sure where XDG_CURRENT_DESKTOP comes from)
            gtk = true; # I think this is also the default...
          };
          xwayland = false;
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
            gaps = { inner = 0; outer = 0; };
            window.border = 6;
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
            input = hostinputs;
            output = {
              "${out_aw3418dw}" = {
                mode = "3440x1440@120Hz";
                pos = "0 0";
                #mode = "3440x1440Hz";
                # don't force alienware to be a certain refresh rate (it depends what adapter is used :/)
                subpixel = "rgb";
                scale = "1.0";
                adaptive_sync = "on";
              };
              #"${out_aw3418dw}" = { disable = ""; };
              "${out_carbon}" = {
                mode = "2880x1800@90Hz";
                pos = "3440 0";
                subpixel = "rgb";
                scale = "1.8";
                adaptive_sync = "on";
                #render_bit_depth = "10";
              };
              "${out_lgc165}" = {
                disable = "";
              };
              "${out_rpi4_lgc165}" = {
                mode = "1920x1080@60.000Hz";
              };
              "*" = {
                background = background;
              };
            };
            bars = [ ];
            # bars = [{
            #   command = statusCommand;
            #   # mode = "hide";
            #   # hiddenState = "hide";
            #   # modifier = "Mod4";
            # }];
            keybindings = {
              "${modifier}+Return" = "exec ${terminal}";
              "${modifier}+Shift+q" = "kill";
              "${modifier}+Shift+c" = "reload";
              "${modifier}+Delete" = "exec ${swaylock}";

              # "${modifier}+Tab" = "exec ${pkgs.wldash}/bin/wldash";
              "${modifier}+Escape" = "exec ${prefs.default_launcher}";
              "${modifier}+Ctrl+Alt+Delete" = "exec ${swaymsg} exit || true";
              "${modifier}+Ctrl+Alt+Insert" = "exec ${swaymsg} reload";

              "${modifier}+Ctrl+Alt+F12" = "exec ${pkgs.procps}/bin/pkill -9 -f remote-viewer";

              "${modifier}+Alt+F1" = "exec ${cmd_pass}";
              "${modifier}+Alt+F2" = "exec ${cmd_totp}";
              "${modifier}+Alt+F3" = "exec ${cmd_empi}";
              "${modifier}+F1" = "exec ${cmd_pass}";
              "${modifier}+F2" = "exec ${cmd_totp}";
              "${modifier}+F3" = "exec ${cmd_empi}";

              # I gotta fucking learn some day
              #"${modifier}+Left" = "focus left";
              #"${modifier}+Down" = "focus down";
              #"${modifier}+Up" = "focus up";
              #"${modifier}+Right" = "focus right";
              #"${modifier}+Shift+Left" = "move left";
              #"${modifier}+Shift+Down" = "move down";
              #"${modifier}+Shift+Up" = "move up";
              #"${modifier}+Shift+Right" = "move right";

              "${modifier}+h" = "focus left";
              "${modifier}+j" = "focus down";
              "${modifier}+k" = "focus up";
              "${modifier}+l" = "focus right";

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
