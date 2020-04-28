{ pkgs, firefoxNightly, ... }:

let
  blue = "'#004059'";
  purple = "'#3d326e'";
  purpledark = "'#1b104d'";
  swayfont = "Noto Sans Mono Bold 9";
  barfont = "Noto Sans Mono Bold 9";

  terminal = "${pkgs.termite}/bin/termite";
  browser = "${firefoxNightly}/bin/firefox-nightly -P default";
  editor = "${pkgs.vscodium}/bin/codium";
  menu = "${pkgs.wofi}/bin/wofi --show drun";

  # output identifiers
  out_laptop = "Sharp Corporation 0x148B 0x00000000";
  out_alien = "Dell Inc. Dell AW3418DW #ASPD8psOnhPd";

  # input identifiers
  in_touchpad = "1739:30383:DELL07E6:00_06CB:76AF_Touchpad";
  in_logi = "1133:16505:Logitech_G_Pro";

  i3statusConfig = import ./i3status-rust-config.nix { inherit pkgs; };

  # idle/lock
  # TODO: test and fix/ remove this message
  swaylockcmd = "${pkgs.swaylock}/bin/swaylock -f -c '#000000'";
  idlecmd = ''${pkgs.swayidle}/bin/swayidle -w \
    before-sleep \"${swaylockcmd}\" \
    lock \"${swaylockcmd}\" \
    timeout 500 \"${swaylockcmd}\" \
    timeout 1000 \"${pkgs.systemd}/bin/systemctl suspend\"'';

  # silly gtk/gnome wayland schenanigans
  gsettingsscript = pkgs.writeShellScript "gsettings-auto.sh" ''
    expression=""
    for pair in "$@"; do
      IFS=:; set -- $pair
      expressions="$expressions -e 's:^$2=(.*)$:gsettings set org.gnome.desktop.interface $1 \1:e'"
    done
    IFS=
    eval exec sed -E $expressions "''${XDG_CONFIG_HOME:-$HOME/.config}"/gtk-3.0/settings.ini >/dev/null
  '';
  gsettingscmd = ''${gsettingsscript} \
    gtk-theme:gtk-theme-name \
    icon-theme:gtk-icon-theme-name \
    cursor-theme:gtk-cursor-theme-name'';

  # change output scales incrementally w/ kb shortcuts
  outputScale = pkgs.writeShellScript "scale-wlr-outputs.sh" ''
    set -xeuo pipefail
    delta=''${1}

    scale="$(swaymsg -t get_outputs | ${pkgs.jq}/bin/jq '.[] | select(.focused == true) | .scale')"
    printf -v scale "%.1f" "''${scale}"
    scale="$(echo "''${scale} ''${delta}" | ${pkgs.bc}/bin/bc)"

    swaymsg output "-" scale "''${scale}"
  '';
in {
  enable = true;
  wrapperFeatures = { gtk = true; };
  xwayland = true;
  config = rec {
    modifier = "Mod4";
    inherit terminal menu;
    fonts = [ swayfont ];
    #focus.followMouse = "always";
    focus.followMouse = true;
    window.border = 4 ;
    window.commands = [
      { criteria = { app_id = "mpv"; }; command = "sticky enable"; }
      { criteria = { app_id = "mpv"; }; command = "floating enable"; }

      {
        criteria = { title = "^(.*) Indicator"; };
        command = "floating enable";
      }
    ];
    startup = [
      { command = "${pkgs.xorg.xrdb}/bin/xrdb -l $HOME/.Xresources";
        always = false; }
      { command = "${pkgs.systemd}/bin/systemd-notify --ready || true";
        always = false; }
      { command = "${idlecmd}";
        always = true; }
      { command = "${gsettingscmd}";
        always = true; }
    ];
    input = {
      "${in_touchpad}" = {
        click_method = "clickfinger";
        tap = "enabled";
        dwt = "enabled";
        scroll_method = "two_finger";
        natural_scroll = "enabled";
        accel_profile = "adaptive";
        pointer_accel = "1";
      };
      "${in_logi}" = {
        accel_profile = "adaptive";
        pointer_accel = ".1";
      };
    };
    output = {
      "*".background = "${blue} solid_color";
      "${out_laptop}" = {
        mode = "3480x2160@59.997002Hz";
        subpixel = "rgb";
        scale = "2.0";
      };
      "${out_alien}" = {
        mode = "3440x1440@100Hz";
        subpixel = "rgb";
        scale = "1.0";
        adaptive_sync = "on";
      };
    };
    bars = [{
      fonts = [ barfont ];
      position = "top";
      statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ${i3statusConfig}";
    }];
    keybindings = {
      "${modifier}+Return" = "exec ${terminal}";
      "${modifier}+Shift+Return" = "exec ${browser}";
      "${modifier}+Shift+Backspace" = "exec ${editor}";
      "${modifier}+Shift+q" = "kill";
      "${modifier}+Escape" = "exec ${menu}";
      "${modifier}+Shift+c" = "reload";
      "Ctrl+Escape" = "exec ${pkgs.wldash}/bin/wldash start-or-kill";

      "${modifier}+Ctrl+Alt+Delete" = "exit";

      "${modifier}+q" = "exec echo"; # the most ridiculous firefox bug ever

      "${modifier}+Left" = "focus left";
      "${modifier}+Down" = "focus down";
      "${modifier}+Up" = "focus up";
      "${modifier}+Right" = "focus right";

      "${modifier}+Shift+Left" = "move left";
      "${modifier}+Shift+Down" = "move down";
      "${modifier}+Shift+Up" = "move up";
      "${modifier}+Shift+Right" = "move right";

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

      "${modifier}+1" = "workspace number 01";
      "${modifier}+2" = "workspace number 02";
      "${modifier}+3" = "workspace number 03";
      "${modifier}+4" = "workspace number 04";
      "${modifier}+5" = "workspace number 05";
      "${modifier}+6" = "workspace number 06";
      "${modifier}+7" = "workspace number 07";
      "${modifier}+8" = "workspace number 08";
      "${modifier}+9" = "workspace number 09";
      "${modifier}+0" = "workspace number 10";

      "${modifier}+Shift+1" = "move container to workspace number 01";
      "${modifier}+Shift+2" = "move container to workspace number 02";
      "${modifier}+Shift+3" = "move container to workspace number 03";
      "${modifier}+Shift+4" = "move container to workspace number 04";
      "${modifier}+Shift+5" = "move container to workspace number 05";
      "${modifier}+Shift+6" = "move container to workspace number 06";
      "${modifier}+Shift+7" = "move container to workspace number 07";
      "${modifier}+Shift+8" = "move container to workspace number 08";
      "${modifier}+Shift+9" = "move container to workspace number 09";
      "${modifier}+Shift+0" = "move container to workspace number 10";

      "${modifier}+Shift+minus" = "move scratchpad";
      "${modifier}+minus" = "scratchpad show";

      "${modifier}+Ctrl+Alt+Home" = "output * enable";
      "${modifier}+Ctrl+Alt+End" = "output -- disable";
      "${modifier}+Ctrl+Alt+equal" = "exec ${outputScale} +.1";
      "${modifier}+Ctrl+Alt+minus" = "exec ${outputScale} -.1";

      "${modifier}+Print"       = ''exec ${pkgs.grim}/bin/grim \"''${HOME}/screenshot-$(date '+%s').png\"'';
      "${modifier}+Shift+Print" = ''exec ${pkgs.grim}/bin/grim  -g \"$(slurp)\" \"''${HOME}/screenshot-$(date '+%s').png\"'';

      # ###############################################################################
      # # gopass
      # set $gopass_show gopass ls --flat | fzf | xargs -r swaymsg -t command exec -- gopass show --clip
      # set $gopass_totp gopass ls --flat | fzf | xargs -r swaymsg -t command exec -- gopass totp --clip
      # set $termite_gopass_show exec termite --name=launcher -e 'bash -c "$gopass_show"'
      # set $termite_gopass_totp exec termite --name=launcher -e 'bash -c "$gopass_totp"'
      # bindsym $mod+F1 $termite_gopass_show
      # bindsym $mod+F2 $termite_gopass_totp
      # ###############################################################################

      "${modifier}+Ctrl+Alt+Up"   = "exec ${pkgs.brightnessctl}/bin/brightnessctl set +10";
      "${modifier}+Ctrl+Alt+Down" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 10-";
      "${modifier}+Ctrl+Alt+Prior"   = "exec ${pkgs.brightnessctl}/bin/brightnessctl set +100";
      "${modifier}+Ctrl+Alt+Next" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 100-";
      "${modifier}+Ctrl+Alt+Left" = "exec ${pkgs.pulsemixer}/bin/pulsemixer --change-volume -2";
      "${modifier}+Ctrl+Alt+Right" = "exec ${pkgs.pulsemixer}/bin/pulsemixer --change-volume +2";
    };
  };
}
