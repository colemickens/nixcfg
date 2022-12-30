{ pkgs, lib, config, inputs, ... }:

let
  _xwayland = {
    enable = _xwayland;
    hidpiXwayland = _xwayland;
  };
in
{
  imports = [
    ./gui-wayland.nix

    inputs.hyprland.nixosModules.default
  ];
  config = {
    programs.hyprland = {
      enable = true;
      # xwayland = _xwayland;
    };

    home-manager.users.cole = { pkgs, ... }: {
      imports = [
        inputs.hyprland.homeManagerModules.default
      ];
      wayland.windowManager.hyprland = {
        enable = true;
        systemdIntegration = true;
        recommendedEnvironment = true;
        # xwayland = _xwayland;
      };
    };
  };
}
