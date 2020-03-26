{ pkgs, ... }:

{
  imports = [
    ./base.nix
    ../../modules/profile-sway.nix
  ];

  # sudo -s
  # export NIX_PATH=nixpkgs=/home/cole/code/nixpkgs:nixos-config=/home/cole/code/nixcfg/machines/slynux/sway.nix
  # nixos-rebuild switch

  nix.nixPath = [
    "nixpkgs=/home/cole/code/nixpkgs"
    "nixos-config=/home/cole/code/nixcfg/machines/slynux/sway.nix"
  ];
}
