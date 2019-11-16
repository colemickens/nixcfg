{ pkgs, ... }:

{
  imports = [
    ./base.nix
    ../modules/profile-gnome.nix
  ];
}
