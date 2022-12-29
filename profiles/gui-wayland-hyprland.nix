{ pkgs, lib, config, inputs, ... }:

{
  imports = [
    ../gui-wayland.nix

    inputs.hyprland.nixosModules.default
    inputs.hyprland.homeManagerModules.default
  ];
  config = {
    programs.hyprland = {
      enable = true;
    };

    home-manager.users.cole = { pkgs, ... }: {
      programs.hyprland = {
        enable = true;
        systemdIntegration = true;
        recommendedEnvironment = true;
      };
    };
  };
}
