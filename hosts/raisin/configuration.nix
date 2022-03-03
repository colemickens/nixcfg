{ config, pkgs, ... }:

let
  extraSpecial = false;
in {
  imports = [
    #../../profiles/desktop-wayfire.nix
    #../../profiles/desktop-fireplace.nix
    ../../profiles/desktop-sway-unstable.nix
    ./core.nix
  ];

  config = {
    specialisation = if !extraSpecial then {} else {
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
