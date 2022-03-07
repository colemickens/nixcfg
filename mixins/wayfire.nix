{ config, pkgs, inputs, ... }:

let
  bg_gruvbox_rainbow = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/lunik1/nixos-logo-gruvbox-wallpaper/master/png/gruvbox-dark-rainbow.png";
    sha256 = "036gqhbf6s5ddgvfbgn6iqbzgizssyf7820m5815b2gd748jw8zc";
  };
  bgcolor = "#000000";

  fmt = pkgs.formats.ini { };
  gen = cfg: (fmt.generate "wayfire-config.ini" cfg);

  #lockcmd = "${pkgs.swaylock}/bin/swaylock -c \#cccccc";
  idlelockcmd = "${pkgs.swaylock-effects}/bin/swaylock --screenshots --clock --effect-scale 0.5 --effect-blur 7x5 --effect-scale 2 --effect-pixelate 10";
  lockcmd = "${pkgs.swaylock-effects}/bin/swaylock --screenshots --clock --fade-in 5 --effect-scale 0.5 --effect-blur 7x5 --effect-scale 2 --effect-pixelate 10";
in
{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      xdg.configFile."wayfire.ini".source = gen {
        "input" = {
          click_method = "clickfinger";
          disable_touchpad_while_type = true;
          natural_scroll = true;
        };
        "output:DP-1" = {
          mode = "3440x1440@120000";
        };
        "output:eDP-1" = {
          mode = "2880x1800@90000";
          scale = 1.5;
        };
        "output:HDMI-A-1" = {
          enabled = false;
        };
        core = {
          plugins = (builtins.concatStringsSep " " [
            "alpha"
            "animate"
            "autostart"
            "blur"
            "command"
            #"cube"
            "decoration"
            "expo"
            "fast-switcher"
            "fisheye"
            "follow-focus"
            #"grid"
            "idle"
            "invert"
            "move"
            "oswitch"
            "place"
            "resize"
            "switcher"
            "vswitch"
            "simple-tile"
            "window-rules"
            "wm-actions"
            #"wobbly"
            "wrot"
            "zoom"
          ]);
          close_top_view = "<super> <shift> KEY_Q | <alt> KEY_F4";
          vwidth = 2;
          vheight = 2;
          preferred_decoration_mode = "server";
        };

        # Mouse bindings ───────────────────────────────────────────────────────────────
        move.activate = "<super> BTN_LEFT";
        resize.activate = "<super> BTN_RIGHT";
        zoom.modifier = "<super>";
        alpha.modifier = "<super> <alt>";
        wrot.activate = "<super> <ctrl> BTN_RIGHT";
        fisheye.toggle = "<super> <ctrl> KEY_F";

        autostart = {
          autostart_wf_shell = false;
          # background = wf-background
          # panel = wf-panel
          # dock = wf-dock
          import = "systemctl import-environment --user WAYLAND_DISPLAY XDG_SESSION_TYPE XDG_SESSION_ID";
          panel = "waybar -l trace > /tmp/waybar.trace.txt"; # configured with hm
          outputs = "${pkgs.kanshi}/bin/kanshi";
          notifications = "mako"; # configured with hm
          gamma = "${pkgs.wlsunset}/bin/wlsunset -l 47.6062 -L 122.3321"; # aha, lol, this is why I can't disable it?
          idle = "${pkgs.swayidle}/bin/swayidle before-sleep '${idlelockcmd}'";

          # XDG desktop portal
          # Needed by some GTK applications
          # portal = /usr/libexec/xdg-desktop-portal
        };

        idle = {
          toggle = "<super> KEY_Z";
          screensaver_timeout = 300;
          dpms_timeout = 600;
        };

        command = {
          binding_terminal = "<super> KEY_ENTER";
          command_terminal = "wezterm";

          binding_launcher = "<super> KEY_ESC";
          command_launcher = "${pkgs.sirula}/bin/sirula";

          binding_lock = "<super> <shift> KEY_DELETE | <super> KEY_DELETE";
          command_lock = "${lockcmd}";

          #binding_logout = <super> KEY_ESC
          #command_logout = wlogout

          binding_screenshot = "<super> KEY_PRINT";
          command_screenshot = "grim $(date '+%F_%T').webp";

          binding_screenshot_interactive = "<super> <shift> KEY_PRINT";
          command_screenshot_interactive = "slurp | grim -g - $(date '+%F_%T').webp";
        };
        /*
          # Volume controls
          # https://alsa-project.org
          repeatable_binding_volume_up = KEY_VOLUMEUP
          command_volume_up = amixer set Master 5%+
          repeatable_binding_volume_down = KEY_VOLUMEDOWN
          command_volume_down = amixer set Master 5%-
          binding_mute = KEY_MUTE
          command_mute = amixer set Master toggle
        
          # Screen brightness
          # https://haikarainen.github.io/light/
          repeatable_binding_light_up = KEY_BRIGHTNESSUP
          command_light_up = light -A 5
          repeatable_binding_light_down = KEY_BRIGHTNESSDOWN
          command_light_down = light -U 5
         
        */
        wm-actions = {
          toggle_fullscreen = "<super> KEY_F";
          toggle_always_on_top = "<super> KEY_X";
          toggle_sticky = "<super> <shift> KEY_X";
        };

        grid = {
          #
          # ⇱ ↑ ⇲   │ 7 8 9
          # ← f →   │ 4 5 6
          # ⇱ ↓ ⇲ d │ 1 2 3 0
          # ‾   ‾
          slot_bl = "<super> KEY_KP1";
          slot_b = "<super> KEY_KP2";
          slot_br = "<super> KEY_KP3";
          slot_l = "<super> KEY_LEFT | <super> KEY_KP4";
          slot_c = "<super> KEY_UP | <super> KEY_KP5";
          slot_r = "<super> KEY_RIGHT | <super> KEY_KP6";
          slot_tl = "<super> KEY_KP7";
          slot_t = "<super> KEY_KP8";
          slot_tr = "<super> KEY_KP9";
          # Restore default.
          restore = "<super> KEY_DOWN | <super> KEY_KP0";
        };
        # Change active window with an animation.
        switcher = {
          next_view = "<alt> KEY_TAB";
          prev_view = "<alt> <shift> KEY_TAB";
        };

        # Simple active window switcher.
        fast-switcher = {
          activate = "<alt> KEY_ESC";
        };

        vswitch = {
          binding_left = "<ctrl> <super> KEY_LEFT";
          binding_down = "<ctrl> <super> KEY_DOWN";
          binding_up = "<ctrl> <super> KEY_UP";
          binding_right = "<ctrl> <super> KEY_RIGHT";
          # Move the focused window with the same key-bindings, but add Shift.
          with_win_left = "<ctrl> <super> <shift> KEY_LEFT";
          with_win_down = "<ctrl> <super> <shift> KEY_DOWN";
          with_win_up = "<ctrl> <super> <shift> KEY_UP";
          with_win_right = "<ctrl> <super> <shift> KEY_RIGHT";
        };

        # Show the current workspace row as a cube.
        cube = {
          activate = "<ctrl> <alt> BTN_LEFT";
          # Switch to the next or previous workspace.
          #rotate_left = <super> <ctrl> KEY_H
          #rotate_right = <super> <ctrl> KEY_L
        };

        # Show an overview of all workspaces.
        expo = {
          toggle = "<super>";
          # Workspaces are arranged into a grid of 3 × 3.
          # The numbering is left to right, line by line.
          #
          # ⇱ k ⇲
          # h ⏎ l
          # ⇱ j ⇲
          # ‾   ‾
          select_workspace_1 = "KEY_1";
          select_workspace_2 = "KEY_2";
          select_workspace_3 = "KEY_3";
          select_workspace_4 = "KEY_4";
          select_workspace_5 = "KEY_5";
          select_workspace_6 = "KEY_6";
          select_workspace_7 = "KEY_7";
          select_workspace_8 = "KEY_8";
          select_workspace_9 = "KEY_9";
        };
        oswitch = {
          next_output = "<super> KEY_O";
          next_output_with_win = "<super> <shift> KEY_O";
        };
        invert = {
          toggle = "<super> KEY_I";
        };
        window-rules = {
          # maximize_alacritty = on created if app_id is "Alacritty" then maximize
        };
      };
    };
  };
}
