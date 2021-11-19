{ config, pkgs, ... }:

{
  imports = [
    ./core.nix
  ];

  config = {
    specialisation = {
      gnome.inheritParentConfig = false;
      gnome.configuration.imports = [
        ./core.nix
        ../../profiles/desktop-gnome.nix
      ];

      sway.inheritParentConfig = false;
      sway.configuration.imports = [
        ./core.nix
        ../../profiles/desktop-sway-unstable-egl.nix
      ];

      plasma.inheritParentConfig = false;
      plasma.configuration.imports = [
        ./core.nix
        ../../profiles/desktop-plasma.nix
      ];
    };
  };
}
