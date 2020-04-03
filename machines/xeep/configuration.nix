{ pkgs, ... }:

{
  imports = [
    ./base.nix

    #../../modules/profile-gnome.nix
    #../../modules/profile-plasma.nix
    ../../modules/profile-sway.nix
  ];

  nix.nixPath = [];
}
