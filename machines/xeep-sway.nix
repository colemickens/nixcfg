{ pkgs, ... }:

{
  imports = [
    ./xeep-base.nix
    ../modules/profile-sway.nix
  ];
}
