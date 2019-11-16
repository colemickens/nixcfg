{ pkgs, ... }:

{
  imports = [
    ./base.nix
    ../modules/profile-plasma.nix
  ];
}
