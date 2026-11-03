{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  cfg = config.nixcfg.desktop.umbriel-gpui-shell;
  umbrielPkg = inputs.umbriel.packages.${pkgs.stdenv.hostPlatform.system}.default;
  gpuiShellPkg = inputs.gpui-shell.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  imports = [
    ./gui-wayland.nix
    inputs.umbriel.nixosModules.default
    ../mixins/greetd.nix
  ];

  options = {
    nixcfg.desktop.umbriel-gpui-shell = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to enable the Umbriel + gpui-shell desktop profile.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.umbriel = {
      enable = true;
    };

    environment.systemPackages = with pkgs; [
      umbrielPkg
      gpuiShellPkg
      xwayland-satellite
      playerctl
      swaylock
    ];

    home-manager.users.cole =
      { pkgs, ... }:
      {
        imports = [
          inputs.umbriel.homeModules.default
        ];

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

        programs.umbriel = {
          enable = true;
          settings = {
            general = {
              autostart = [ "gpuishell" ];
            };
            input = {
              focus_follows_mouse = true;
              touchpad = {
                natural_scroll = true;
                tap_to_click = true;
              };
            };
            keybinds = {
              "Mod+T" = "spawn:ghostty";
              "Mod+Return" = "spawn:ghostty";
              "Mod+D" = "spawn:gpuishell";
              "Mod+Space" = "spawn:gpuishell";
              "Super+Alt+L" = "spawn:swaylock";
              "Mod+Q" = "window-close";
              "Alt+F4" = "window-close";
            };
          };
        };
      };
  };
}
