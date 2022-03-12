{ config, pkgs, inputs, lib, ... }:

let
  prefs = import ./_preferences.nix { inherit config pkgs inputs lib; };

  fmt = pkgs.formats.ini { };
  gen = cfg: (fmt.generate "wayfire.ini" cfg);

  default_term = prefs.default_term;
  default_launcher = prefs.default_launcher;
  lockcmd = prefs.lockcmd;
  idlelockcmd = prefs.idlelockcmd;
  bgcolor = prefs.bgcolor;
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
          mode = "off";
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
          background_color = bgcolor;
          close_top_view = "<super> <shift> KEY_Q | <alt> KEY_F4";
          vwidth = 2;
          vheight = 2;
          preferred_decoration_mode = "server";
          xwayland = prefs.xwayland_enabled;
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
          import = prefs.poststart;
          panel = "waybar"; # configured with hm
          outputs = "${pkgs.kanshi}/bin/kanshi";
          notifications = "mako"; # configured with hm
          gamma = "${pkgs.wlsunset}/bin/wlsunset -l 47.6062 -L 122.3321"; # aha, lol, this is why I can't disable it?
          idle = "${pkgs.swayidle}/bin/swayidle before-sleep \"${idlelockcmd}\"";
        };

        command = {
          binding_terminal = "<super> KEY_ENTER";
          command_terminal = default_term;

          binding_launcher = "<super> KEY_ESC";
          command_launcher = default_launcher;

          binding_lock = "<super> KEY_DELETE";
          command_lock = lockcmd;

          binding_logout = "<ctrl> <alt> <super> KEY_DELETE";
          command_logout = "${pkgs.bash}/bin/bash -c \"${pkgs.systemd}/bin/loginctl terminate-session $XDG_SESSION_ID\"";

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

        simple-tile = {
          key_toggle = "<super> KEY_SPACE";
          inner_gap_size = 0;
          animation_duration = 2;
        };

        fast-switcher = {
          activate = "<super> KEY_TAB";
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
