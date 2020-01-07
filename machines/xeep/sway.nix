{ pkgs, ... }:

{
  imports = [
    ./base.nix
    ../../modules/profile-sway.nix
  ];

  nix.nixPath = [
    "nixpkgs=/home/cole/code/nixpkgs"
    "nixos-config=/home/cole/code/nixcfg/machines/xeep/sway.nix"
  ];
}
