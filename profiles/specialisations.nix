{ config, pkgs, inputs, ... }:
{
  config = {
    specialisation = {
      sway.configuration = {
        boot.loader.grub.configurationName = "sway";
        imports = [ ./desktop-sway.nix ];
      };
      sway-unstable.configuration = {
        boot.loader.grub.configurationName = "sway-unstable";
        imports = [ ./desktop-sway.nix ];
        nixpkgs.config.overlays = [
          inputs.nixpkgs-wayland.overlay
        ];
      };
      gnome.configuration = {
        boot.loader.grub.configurationName = "gnome";
        imports = [ ./desktop-gnome.nix ];
      };
      plasma.configuration = {
        boot.loader.grub.configurationName = "plasma";
        imports = [ ./desktop-plasma.nix ];
      };
      elementary.configuration = {
        boot.loader.grub.configurationName = "elementary";
        imports = [ ./desktop-elementary.nix ];
      };
    };
  };
}