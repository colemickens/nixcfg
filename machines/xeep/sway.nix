{ pkgs, ... }:

{
  imports = [
    ./xeep-base.nix
    ../modules/profile-sway.nix
    ../modules/mixin-intel-iris.nix
  ];
}
