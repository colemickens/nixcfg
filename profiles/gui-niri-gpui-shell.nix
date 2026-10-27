{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  cfg = config.nixcfg.desktop.niri-gpui-shell;
  niriPkg = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.default;
  gpuiShellPkg = inputs.gpui-shell.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  imports = [
    ./gui-wayland.nix
  ];

  options = {
    nixcfg.desktop.niri-gpui-shell = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enable the Niri + gpui-shell desktop profile.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.niri = {
      enable = true;
      package = niriPkg;
    };

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd ${niriPkg}/bin/niri-session";
          user = "greeter";
        };
      };
    };

    services.supergfxd.enable = false;

    environment.systemPackages = with pkgs; [
      gpuiShellPkg
      xwayland-satellite
      playerctl
      swaylock
    ];

    home-manager.users.cole =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          wpaperd
        ];

        services.wpaperd = {
          enable = true;
          settings = {
            default = {
              path = pkgs.fetchurl {
                name = "wallpaper.jpg";
                url = "https://github.com/dharmx/walls/blob/main/abstract/a_colorful_swirls_of_paint.jpg?raw=true";
                hash = "sha256-jOA4DZX3bEV+7Bmi+uAnVvOLxaSrbqPeJMyzcSSiVNo=";
              };
            };
          };
        };

        xdg.configFile."gpuishell/config.toml".text = ''
          [bar]
          size = 36.0
          position = "top"
          start = ["Workspaces", "SysInfo"]
          center = ["ActiveWindow"]
          end = ["Clock", "Mpris", "Notifications", "Systray", "KeyboardLayout", "Battery", "Settings"]
          style = "attached"

          [launcher]
          width = 600.0
          height = 450.0
          margin_top = 100.0
          margin_right = 0.0
          margin_bottom = 0.0
          margin_left = 0.0

          [osd]
          position = "right"

          [control_center.power_actions]
          sleep = "systemctl suspend"
          reboot = "systemctl reboot"
          poweroff = "systemctl poweroff"
        '';

        xdg.configFile."niri/config.kdl".text = ''
          input {
              focus-follows-mouse max-scroll-amount="10%"
              keyboard {
                  xkb {
                  }
                  numlock
              }

              touchpad {
                  tap
                  natural-scroll
                  click-method "clickfinger"
                  dwt
                  middle-emulation
              }

              mouse {
              }

              trackpoint {
              }
          }

          prefer-no-csd
          layout {
              gaps 12
              center-focused-column "never"

              preset-column-widths {
                  proportion 0.33333
                  proportion 0.5
                  proportion 0.66667
              }

              default-column-width { proportion 0.5; }

              focus-ring {
                  width 4
                  active-color "#7fc8ff"
                  inactive-color "#505050"
              }

              border {
                  off
                  width 4
                  active-color "#ffc87f"
                  inactive-color "#505050"
                  urgent-color "#9b0000"
              }

              shadow {
                  softness 30
                  spread 5
                  offset x=0 y=5
                  color "#0007"
              }
          }

          spawn-at-startup "gpuishell"

          screenshot-path "~/Screenshot from %Y-%m-%d %H-%M-%S.png"

          window-rule {
              geometry-corner-radius 12
              clip-to-geometry true
              draw-border-with-background false
          }

          window-rule {
              match app-id=r#"^org\.wezfurlong\.wezterm$"#
              default-column-width {}
          }

          window-rule {
              match app-id=r#"firefox$"# title="^Picture-in-Picture$"
              open-floating true
          }

          binds {
              Mod+Shift+Slash { show-hotkey-overlay; }

              Mod+T hotkey-overlay-title="Open a Terminal: ghostty" { spawn "ghostty"; }
              Mod+D hotkey-overlay-title="Open Launcher: gpuishell" { spawn "gpuishell"; }
              Mod+Space hotkey-overlay-title="Open Launcher: gpuishell" { spawn "gpuishell"; }
              Super+Alt+L hotkey-overlay-title="Lock the Screen: swaylock" { spawn "swaylock"; }

              XF86AudioRaiseVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0"; }
              XF86AudioLowerVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"; }
              XF86AudioMute        allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; }
              XF86AudioMicMute     allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; }

              XF86AudioPlay        allow-when-locked=true { spawn-sh "playerctl play-pause"; }
              XF86AudioPause       allow-when-locked=true { spawn-sh "playerctl play-pause"; }
              XF86AudioStop        allow-when-locked=true { spawn-sh "playerctl stop"; }
              XF86AudioPrev        allow-when-locked=true { spawn-sh "playerctl previous"; }
              XF86AudioNext        allow-when-locked=true { spawn-sh "playerctl next"; }

              XF86MonBrightnessUp   allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "+10%"; }
              XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "10%-"; }

              XF86TouchpadToggle repeat=false { toggle-touchpad; }

              Mod {
                  release { toggle-overview; }
              }

              Mod+Q repeat=false { close-window; }
              Alt+F4 repeat=false { close-window; }

              Mod+Left  { focus-column-left; }
              Mod+Down  { focus-window-down; }
              Mod+Up    { focus-window-up; }
              Mod+Right { focus-column-right; }
              Mod+H     { focus-column-left; }
              Mod+J     { focus-window-down; }
              Mod+K     { focus-window-up; }
              Mod+L     { focus-column-right; }

              Mod+Ctrl+Left  { move-column-left; }
              Mod+Ctrl+Down  { move-window-down; }
              Mod+Ctrl+Up    { move-window-up; }
              Mod+Ctrl+Right { move-column-right; }
              Mod+Ctrl+H     { move-column-left; }
              Mod+Ctrl+J     { move-window-down; }
              Mod+Ctrl+K     { move-window-up; }
              Mod+Ctrl+L     { move-column-right; }

              Mod+Home      { focus-column-first; }
              Mod+End       { focus-column-last; }
              Mod+Ctrl+Home { move-column-to-first; }
              Mod+Ctrl+End  { move-column-to-last; }

              Mod+Shift+Left  { focus-monitor-left; }
              Mod+Shift+Down  { focus-monitor-down; }
              Mod+Shift+Up    { focus-monitor-up; }
              Mod+Shift+Right { focus-monitor-right; }
              Mod+Shift+H     { focus-monitor-left; }
              Mod+Shift+J     { focus-monitor-down; }
              Mod+Shift+K     { focus-monitor-up; }
              Mod+Shift+L     { focus-monitor-right; }

              Mod+Shift+Ctrl+Left  { move-column-to-monitor-left; }
              Mod+Shift+Ctrl+Down  { move-column-to-monitor-down; }
              Mod+Shift+Ctrl+Up    { move-column-to-monitor-up; }
              Mod+Shift+Ctrl+Right { move-column-to-monitor-right; }
              Mod+Shift+Ctrl+H     { move-column-to-monitor-left; }
              Mod+Shift+Ctrl+J     { move-column-to-monitor-down; }
              Mod+Shift+Ctrl+K     { move-column-to-monitor-up; }
              Mod+Shift+Ctrl+L     { move-column-to-monitor-right; }

              Mod+Page_Down      { focus-workspace-down; }
              Mod+Page_Up        { focus-workspace-up; }
              Mod+U              { focus-workspace-down; }
              Mod+I              { focus-workspace-up; }
              Mod+Ctrl+Page_Down { move-column-to-workspace-down; }
              Mod+Ctrl+Page_Up   { move-column-to-workspace-up; }
              Mod+Ctrl+U         { move-column-to-workspace-down; }
              Mod+Ctrl+I         { move-column-to-workspace-up; }

              Mod+Shift+Page_Down { move-workspace-down; }
              Mod+Shift+Page_Up   { move-workspace-up; }
              Mod+Shift+U         { move-workspace-down; }
              Mod+Shift+I         { move-workspace-up; }

              Mod+WheelScrollDown      cooldown-ms=150 { focus-workspace-down; }
              Mod+WheelScrollUp        cooldown-ms=150 { focus-workspace-up; }
              Mod+Ctrl+WheelScrollDown cooldown-ms=150 { move-column-to-workspace-down; }
              Mod+Ctrl+WheelScrollUp   cooldown-ms=150 { move-column-to-workspace-up; }

              Mod+WheelScrollRight      { focus-column-right; }
              Mod+WheelScrollLeft       { focus-column-left; }
              Mod+Ctrl+WheelScrollRight { move-column-right; }
              Mod+Ctrl+WheelScrollLeft  { move-column-left; }

              Mod+Shift+WheelScrollDown      { focus-column-right; }
              Mod+Shift+WheelScrollUp        { focus-column-left; }
              Mod+Ctrl+Shift+WheelScrollDown { move-column-right; }
              Mod+Ctrl+Shift+WheelScrollUp   { move-column-left; }

              Mod+1 { focus-workspace 1; }
              Mod+2 { focus-workspace 2; }
              Mod+3 { focus-workspace 3; }
              Mod+4 { focus-workspace 4; }
              Mod+5 { focus-workspace 5; }
              Mod+6 { focus-workspace 6; }
              Mod+7 { focus-workspace 7; }
              Mod+8 { focus-workspace 8; }
              Mod+9 { focus-workspace 9; }
              Mod+Ctrl+1 { move-column-to-workspace 1; }
              Mod+Ctrl+2 { move-column-to-workspace 2; }
              Mod+Ctrl+3 { move-column-to-workspace 3; }
              Mod+Ctrl+4 { move-column-to-workspace 4; }
              Mod+Ctrl+5 { move-column-to-workspace 5; }
              Mod+Ctrl+6 { move-column-to-workspace 6; }
              Mod+Ctrl+7 { move-column-to-workspace 7; }
              Mod+Ctrl+8 { move-column-to-workspace 8; }
              Mod+Ctrl+9 { move-column-to-workspace 9; }

              Mod+BracketLeft  { consume-or-expel-window-left; }
              Mod+BracketRight { consume-or-expel-window-right; }

              Mod+Comma  { consume-window-into-column; }
              Mod+Period { expel-window-from-column; }

              Mod+R       { switch-preset-column-width; }
              Mod+Shift+R { switch-preset-column-width-back; }

              Mod+Ctrl+Shift+R { switch-preset-window-height; }
              Mod+Ctrl+R       { reset-window-height; }

              Mod+F       { maximize-column; }
              Mod+Shift+F { fullscreen-window; }
              Mod+M       { maximize-window-to-edges; }
              Mod+Ctrl+F  { expand-column-to-available-width; }

              Mod+C      { center-column; }
              Mod+Ctrl+C { center-visible-columns; }

              Mod+Minus { set-column-width "-10%"; }
              Mod+Equal { set-column-width "+10%"; }

              Mod+Shift+Minus { set-window-height "-10%"; }
              Mod+Shift+Equal { set-window-height "+10%"; }

              Mod+V       { toggle-window-floating; }
              Mod+Shift+V { switch-focus-between-floating-and-tiling; }

              Mod+W { toggle-column-tabbed-display; }

              Print      { screenshot; }
              Ctrl+Print { screenshot-screen; }
              Alt+Print  { screenshot-window; }

              Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }

              Mod+Shift+E     { quit; }
              Ctrl+Alt+Delete { quit; }

              Mod+Shift+P { power-off-monitors; }
          }
        '';
      };
  };
}
