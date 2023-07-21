{ config, pkgs, lib, ... }:

{
  imports = [
    ./addon-tiny.nix
  ];

  config = {
    system.nixos.tags = [ "cross" ];
  };
}
