{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  cfg = config.nixcfg.desktop.umbriel-gpui-shell;
  gpuiShellPkg = inputs.gpui-shell.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  imports = [
    ./gui-wayland.nix
    ../mixins/greetd.nix
    ../mixins/umbriel.nix
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
    environment.systemPackages = with pkgs; [
      gpuiShellPkg
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

        programs.umbriel = {
          settings = {
            general = {
              autostart = [ "gpuishell" ];
            };
            keybinds = {
              "Mod+D" = {
                action = "spawn gpuishell";
                repeat = false;
              };
              "Mod+Space" = {
                action = "spawn gpuishell";
                repeat = false;
              };
              "Super+Alt+L" = {
                action = "spawn swaylock";
                repeat = false;
              };
            };
          };
        };
      };
  };
}
