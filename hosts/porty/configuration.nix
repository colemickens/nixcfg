{ config, pkgs, ... }:

{
  imports = [
    ./core.nix

    ../../mixins/gfx-nvidia.nix # because of the wlroots patch, and ordering issues
    ../../profiles/desktop-sway.nix
  ];

 config = {
    specialisation = {
      #gnome.inheritParentConfig = false;
      #gnome.configuration.imports = [
      #  ./core.nix
      #  ../../mixins/nvidia.nix # because of the wlroots patch, and ordering issues
      #  ../../profiles/desktop-gnome.nix
      # ];

      # sway.inheritParentConfig = false;
      # sway.configuration.imports = [
      #   ./core.nix
      #   ../../mixins/gfx-nvidia.nix # because of the wlroots patch, and ordering issues
      #   ../../profiles/desktop-sway-unstable.nix
      # ];
    };
  };
}
