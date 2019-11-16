{ pkgs, ... }:

{
  imports = [
    ./xeep-base.nix
    ../modules/profile-gnome.nix
  ];
}
