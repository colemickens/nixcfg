{ pkgs, ... }:

{
  imports = [
    ./base.nix
    ../../modules/profile-sway.nix
  ];
}
