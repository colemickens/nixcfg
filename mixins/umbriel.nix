{
  inputs,
  ...
}:

{
  imports = [
    inputs.umbriel.nixosModules.default
  ];

  config = {
    programs.umbriel = {
      enable = true;
    };

    home-manager.users.cole =
      { ... }:
      {
        imports = [
          inputs.umbriel.homeModules.default
        ];

        programs.umbriel = {
          enable = true;
          settings = {
            output = {
              "eDP-1" = {
                scale = 1.4;
              };
              "Thermotrex Corporation TL140ADXP01 Unknown" = {
                scale = 1.4;
              };
            };

            input = {
              focus = {
                follows_mouse = true;
                follows_mouse_max_scroll = 0.1;
              };
              keyboard = {
                numlock_toggle = true;
              };
              touchpad = {
                tap = true;
                natural_scroll = true;
                click_method = "clickfinger";
                disable_while_typing = true;
              };
            };

            appearance = {
              prefer_no_csd = true;
              border_width = 4;
              corner_radius = 12;
              blur = {
                radius = 3;
              };
              shadow = {
                enabled = true;
                softness = 30;
                offset_x = 0;
                offset_y = 5;
              };
            };

            colors = {
              shadow = "#00000077";
              border = {
                focused = "#7fc8ffff";
                unfocused = "#505050ff";
              };
            };

            layout = {
              mode = "scrolling";
              gap = 12;
              extent_presets = [
                0.33333
                0.5
                0.66667
              ];
              scrolling = {
                default_extent_fraction = 0.5;
                center_focused = "never";
              };
            };

            window_rule = [
              {
                blur = true;
              }
              {
                match.app_id = "^dev.noctalia.Noctalia$";
                default_floating = true;
                default_floating_size_px = {
                  width = 1020;
                  height = 900;
                };
              }
              {
                match.app_id = "^dev.noctalia.UmbrielSharePicker$";
                default_floating = true;
                default_floating_size_px = {
                  width = 800;
                  height = 600;
                };
              }
              {
                match.title = "^(Picture-in-Picture|Picture in picture)$";
                default_floating = true;
                default_maximize = false;
                default_position = {
                  x = 20;
                  y = 20;
                  anchor = "bottom_right";
                };
              }
              {
                match.title = "^notificationtoasts_.+_desktop";
                default_position = {
                  x = 0;
                  y = 0;
                  anchor = "bottom_right";
                };
                default_focused = false;
                default_pinned = true;
              }
            ];

            hot_corners.top_left = {
              enabled = true;
              delay_ms = 500;
              action = "overview-open";
            };

            keybinds = {
              "Mod+Shift+Slash" = "cheatsheet-toggle";

              "Mod+T" = {
                action = "spawn ghostty";
                repeat = false;
              };
              "Mod+Return" = {
                action = "spawn ghostty";
                repeat = false;
              };

              "XF86AudioRaiseVolume" = {
                action = "spawn wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0";
                allow_when_locked = true;
              };
              "XF86AudioLowerVolume" = {
                action = "spawn wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
                allow_when_locked = true;
              };
              "XF86AudioMute" = {
                action = "spawn wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
                allow_when_locked = true;
                repeat = false;
              };
              "XF86AudioMicMute" = {
                action = "spawn wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
                allow_when_locked = true;
                repeat = false;
              };

              "XF86AudioPlay" = {
                action = "spawn playerctl play-pause";
                allow_when_locked = true;
                repeat = false;
              };
              "XF86AudioPause" = {
                action = "spawn playerctl play-pause";
                allow_when_locked = true;
                repeat = false;
              };
              "XF86AudioStop" = {
                action = "spawn playerctl stop";
                allow_when_locked = true;
                repeat = false;
              };
              "XF86AudioPrev" = {
                action = "spawn playerctl previous";
                allow_when_locked = true;
              };
              "XF86AudioNext" = {
                action = "spawn playerctl next";
                allow_when_locked = true;
              };

              "XF86MonBrightnessUp" = {
                action = "spawn brightnessctl --class=backlight set +10%";
                allow_when_locked = true;
              };
              "XF86MonBrightnessDown" = {
                action = "spawn brightnessctl --class=backlight set 10%-";
                allow_when_locked = true;
              };

              "Mod" = "overview-toggle";
              "Mod+O" = {
                action = "overview-toggle";
                repeat = false;
              };

              "Mod+Q" = {
                action = "window-close";
                repeat = false;
              };
              "Alt+F4" = {
                action = "window-close";
                repeat = false;
              };

              "Mod+Left" = "window-focus-left";
              "Mod+Down" = "window-focus-down";
              "Mod+Up" = "window-focus-up";
              "Mod+Right" = "window-focus-right";
              "Mod+H" = "window-focus-left";
              "Mod+J" = "window-focus-down";
              "Mod+K" = "window-focus-up";
              "Mod+L" = "window-focus-right";

              "Mod+Ctrl+Left" = "column-move-left";
              "Mod+Ctrl+Down" = "window-move-down";
              "Mod+Ctrl+Up" = "window-move-up";
              "Mod+Ctrl+Right" = "column-move-right";
              "Mod+Ctrl+H" = "column-move-left";
              "Mod+Ctrl+J" = "window-move-down";
              "Mod+Ctrl+K" = "window-move-up";
              "Mod+Ctrl+L" = "column-move-right";

              "Mod+Home" = "column-focus-first";
              "Mod+End" = "column-focus-last";
              "Mod+Ctrl+Home" = "column-move-to-first";
              "Mod+Ctrl+End" = "column-move-to-last";

              "Mod+Shift+Left" = "output-focus-left";
              "Mod+Shift+Down" = "output-focus-down";
              "Mod+Shift+Up" = "output-focus-up";
              "Mod+Shift+Right" = "output-focus-right";
              "Mod+Shift+H" = "output-focus-left";
              "Mod+Shift+J" = "output-focus-down";
              "Mod+Shift+K" = "output-focus-up";
              "Mod+Shift+L" = "output-focus-right";

              "Mod+Ctrl+Shift+Left" = "column-move-to-output-left";
              "Mod+Ctrl+Shift+Down" = "column-move-to-output-down";
              "Mod+Ctrl+Shift+Up" = "column-move-to-output-up";
              "Mod+Ctrl+Shift+Right" = "column-move-to-output-right";
              "Mod+Ctrl+Shift+H" = "column-move-to-output-left";
              "Mod+Ctrl+Shift+J" = "column-move-to-output-down";
              "Mod+Ctrl+Shift+K" = "column-move-to-output-up";
              "Mod+Ctrl+Shift+L" = "column-move-to-output-right";

              "Mod+Page_Down" = "workspace-next";
              "Mod+Page_Up" = "workspace-previous";
              "Mod+U" = "workspace-next";
              "Mod+I" = "workspace-previous";
              "Mod+Ctrl+Page_Down" = "column-move-to-workspace-next";
              "Mod+Ctrl+Page_Up" = "column-move-to-workspace-previous";
              "Mod+Ctrl+U" = "column-move-to-workspace-next";
              "Mod+Ctrl+I" = "column-move-to-workspace-previous";

              "Mod+Shift+Page_Down" = "workspace-move-down";
              "Mod+Shift+Page_Up" = "workspace-move-up";
              "Mod+Shift+U" = "workspace-move-down";
              "Mod+Shift+I" = "workspace-move-up";

              "Mod+WheelDown" = {
                action = "workspace-next";
                cooldown_ms = 150;
              };
              "Mod+WheelUp" = {
                action = "workspace-previous";
                cooldown_ms = 150;
              };
              "Mod+Ctrl+WheelDown" = {
                action = "column-move-to-workspace-next";
                cooldown_ms = 150;
              };
              "Mod+Ctrl+WheelUp" = {
                action = "column-move-to-workspace-previous";
                cooldown_ms = 150;
              };

              "Mod+WheelRight" = "window-focus-right";
              "Mod+WheelLeft" = "window-focus-left";
              "Mod+Ctrl+WheelRight" = "column-move-right";
              "Mod+Ctrl+WheelLeft" = "column-move-left";

              "Mod+Shift+WheelDown" = "window-focus-right";
              "Mod+Shift+WheelUp" = "window-focus-left";
              "Mod+Ctrl+Shift+WheelDown" = "column-move-right";
              "Mod+Ctrl+Shift+WheelUp" = "column-move-left";

              "Mod+1" = "workspace-switch 1";
              "Mod+2" = "workspace-switch 2";
              "Mod+3" = "workspace-switch 3";
              "Mod+4" = "workspace-switch 4";
              "Mod+5" = "workspace-switch 5";
              "Mod+6" = "workspace-switch 6";
              "Mod+7" = "workspace-switch 7";
              "Mod+8" = "workspace-switch 8";
              "Mod+9" = "workspace-switch 9";
              "Mod+Ctrl+1" = "column-move-to-workspace 1";
              "Mod+Ctrl+2" = "column-move-to-workspace 2";
              "Mod+Ctrl+3" = "column-move-to-workspace 3";
              "Mod+Ctrl+4" = "column-move-to-workspace 4";
              "Mod+Ctrl+5" = "column-move-to-workspace 5";
              "Mod+Ctrl+6" = "column-move-to-workspace 6";
              "Mod+Ctrl+7" = "column-move-to-workspace 7";
              "Mod+Ctrl+8" = "column-move-to-workspace 8";
              "Mod+Ctrl+9" = "column-move-to-workspace 9";

              "Mod+BracketLeft" = "window-consume-or-expel-left";
              "Mod+BracketRight" = "window-consume-or-expel-right";
              "Mod+Comma" = "window-consume-from-right";
              "Mod+Period" = "window-consume-or-expel-right";

              "Mod+R" = "window-cycle-primary-extent";
              "Mod+Shift+R" = "window-cycle-primary-extent-back";
              "Mod+Ctrl+Shift+R" = "window-cycle-secondary-extent";
              "Mod+Ctrl+R" = "window-set-secondary-extent 0.5";

              "Mod+F" = {
                action = "window-toggle-maximize";
                repeat = false;
              };
              "Mod+Shift+F" = {
                action = "window-toggle-fullscreen";
                repeat = false;
              };
              "Mod+M" = {
                action = "window-toggle-maximize-to-edges";
                repeat = false;
              };
              "Mod+Ctrl+F" = "window-set-primary-extent 1.0";

              "Mod+C" = "column-center";

              "Mod+Minus" = "window-modify-primary-extent -0.1";
              "Mod+Equal" = "window-modify-primary-extent 0.1";
              "Mod+Shift+Minus" = "window-modify-secondary-extent -0.1";
              "Mod+Shift+Equal" = "window-modify-secondary-extent 0.1";

              "Mod+V" = {
                action = "window-toggle-floating";
                repeat = false;
              };
              "Mod+Shift+V" = {
                action = "window-focus-switch-floating";
                repeat = false;
              };

              "Mod+W" = {
                action = "column-toggle-tabbed";
                repeat = false;
              };

              "Mod+Escape" = {
                action = "shortcuts-inhibit-toggle";
                allow_when_inhibited = true;
                repeat = false;
              };

              "Mod+Shift+E" = "session-quit";
              "Ctrl+Alt+Delete" = "session-quit";

              "Mod+Shift+P" = "dpms-off";
            };
          };
        };
      };
  };
}
