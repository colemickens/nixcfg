{ pkgs, ... }:

{
  imports = [
    ./xeep-base.nix
    ../modules/profile-gnomeshell.nix
  ];
}
