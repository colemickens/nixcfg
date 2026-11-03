{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  cfg = config.nixcfg.desktop.umbriel-noctalia;
  umbrielPkg = inputs.umbriel.packages.${pkgs.stdenv.hostPlatform.system}.default;
  noctaliaPkg = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  imports = [
    ./gui-wayland.nix
    inputs.umbriel.nixosModules.default
  ];

  options = {
    nixcfg.desktop.umbriel-noctalia = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to enable the Umbriel + Noctalia desktop profile.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.umbriel = {
      enable = true;
    };

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd ${umbrielPkg}/bin/start-umbriel";
          user = "greeter";
        };
      };
    };

    services.supergfxd.enable = false;

    environment.systemPackages = with pkgs; [
      umbrielPkg
      noctaliaPkg
      xwayland-satellite
      playerctl
      swaylock
    ];

    home-manager.users.cole =
      { pkgs, ... }:
      {
        imports = [
          inputs.umbriel.homeModules.default
          inputs.noctalia.homeModules.default
        ];

        programs.noctalia = {
          enable = true;
          package = noctaliaPkg;
          settings = {
            theme = {
              mode = "dark";
              source = "wallpaper";
            };
          };
        };

        programs.umbriel = {
          enable = true;
          settings = {
            general = {
              autostart = [ "noctalia" ];
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
              "Mod+D" = "spawn:noctalia msg panel-toggle launcher";
              "Mod+Space" = "spawn:noctalia msg panel-toggle launcher";
              "Mod+S" = "spawn:noctalia msg panel-toggle control-center";
              "Super+Alt+L" = "spawn:noctalia msg session lock";
              "Mod+Q" = "window-close";
              "Alt+F4" = "window-close";
            };
          };
        };
      };
  };
}
