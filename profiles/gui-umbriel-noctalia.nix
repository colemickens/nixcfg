{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  cfg = config.nixcfg.desktop.umbriel-noctalia;
  noctaliaPkg = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  imports = [
    ./gui-wayland.nix
    ../mixins/greetd.nix
    ../mixins/umbriel.nix
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
    environment.systemPackages = with pkgs; [
      noctaliaPkg
    ];

    home-manager.users.cole =
      { pkgs, ... }:
      {
        imports = [
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
          settings = {
            general = {
              autostart = [ "noctalia" ];
            };
            layer_rule = [
              {
                match.namespace = "^noctalia-(bar-[^\"]+|notification|dock|panel|attached-panel|osd|desktop-widget-[^\"]*)$";
                blur = true;
                blur_ignore_alpha = 0.5;
                blur_popups = true;
              }
              {
                match.namespace = "^noctalia-(notification|dock|panel|attached-panel|osd)$";
                blur_optimized = false;
              }
            ];
            keybinds = {
              "Mod+D" = {
                action = "spawn noctalia msg panel-toggle launcher";
                repeat = false;
              };
              "Mod+Space" = {
                action = "spawn noctalia msg panel-toggle launcher";
                repeat = false;
              };
              "Mod+S" = {
                action = "spawn noctalia msg panel-toggle control-center";
                repeat = false;
              };
              "Super+Alt+L" = {
                action = "spawn noctalia msg session lock";
                repeat = false;
              };
            };
          };
        };
      };
  };
}
