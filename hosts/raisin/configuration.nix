{ config, pkgs, ... }:

{
  imports = [
    ../../profiles/desktop-sway-unstable.nix
    ./core.nix
  ];

  config = {
    specialisation = {
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
