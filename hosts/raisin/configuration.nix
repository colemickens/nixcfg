{ config, pkgs, ... }:

{
  imports = [
    ../../profiles/desktop-plasma.nix
    ./core.nix
  ];

  config = {
    specialisation = {
      sway = {
        inheritParentConfig = false;
        configuration = {
          imports = [
            ./core.nix
            ../../profiles/desktop-sway-unstable.nix
          ];
        };
      };

      gnome = {
        inheritParentConfig = false;
        configuration = {
          imports = [
            ./core.nix
            ../../profiles/desktop-gnome.nix
          ];
        };
      };

      plasma = {
        inheritParentConfig = false;
        configuration = {
          imports = [
            ./core.nix
            ../../profiles/desktop-plasma.nix
          ];
        };
      };
    };
  };
}
