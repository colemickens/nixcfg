{ config, lib, pkgs, ... }:

with lib;

{
  config = { 
    environment.variables.MOZ_USE_XINPUT2 = "1";

    environment.systemPackages = with pkgs; [
      # firefox-nightly-bin from the mozilla-nixpkgs overlay
      latest.firefox-nightly-bin
    ];
  };
}

