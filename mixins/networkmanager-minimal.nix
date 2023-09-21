{ config, pkgs, lib, ... }:

let
  nmModule = "";
in
{
  config = {
    networking.networkmanager.useMinimalBasePackages = true;
    nixpkgs.overlays = [
      (final: prev: {
        networkmanager = prev.networkmanager.override {
          openconnect = prev.runCommand "openconnect-fake" { } "mkdir -p $out";
        };
      })
    ];
  };
}

