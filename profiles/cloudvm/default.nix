{ config, lib, pkgs, ... }:

let
in {
  imports = [
    ../../users/cole
    ../common
  ];

  networking.firewall.enable = false;

  services = {
    kubernetes = {
      roles = [ "master" "node" ];
    };
  };
}

