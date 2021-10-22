{ config, pkgs, lib, ... }:

let
  nmModule = "";
in
{
  config = {
    networking.networkmanager.useMinimalBasePackages = true;
    nixpkgs.overlays = [(final: prev: {
      networkmanager = prev.networkmanager.override {
        openconnect = prev.runCommandNoCC "openconnet-fake" {} "mkdir -p $out";
      };
    })];
  };
}

