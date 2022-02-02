{ config, pkgs, ... }:

{
  imports = [
    #../../profiles/desktop-sway-unstable.nix
    ../../profiles/desktop-gnome.nix
    ./core.nix
  ];

  config = {
    specialisation = {
      gnome = {
        inheritParentConfig = false;
        configuration = {
          imports = [
            ./core.nix
            ../../profiles/desktop-sway-unstable.nix
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
