{ pkgs, ... }:

{
  imports = [
    ./xeep-base.nix
    ../modules/profile-plasma.nix
  ];
}
