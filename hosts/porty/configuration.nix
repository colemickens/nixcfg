{ config, pkgs, ... }:

{
  imports = [
    ../../profiles/desktop-gnome.nix
    ./core.nix
  ];

  config = {
    specialisation = {
      sway = {
        inheritParentConfig = false;
        configuration = {
          imports = [
            ../../profiles/desktop-sway-unstable-egl.nix
            ./core.nix
          ];
        };
      };
    };
  };
}
