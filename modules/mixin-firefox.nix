{ config, lib, pkgs, ... }:

with lib;

{
  config = { 
    nixpkgs.overlays = [
      (import (builtins.fetchTarball {
        url = "https://github.com/mozilla/nixpkgs-mozilla/archive/c985206e160204707e15a45f0b9df4221359d21c.tar.gz";
	sha256 = "0k0p3nfzr3lfgp1bb52bqrbqjlyyiysf8lq2rnrmn759ijxy2qmq";
      }))
    ];
    environment.variables.MOZ_USE_XINPUT2 = "1";

    environment.systemPackages = with pkgs; [
      # firefox-nightly-bin from the mozilla-nixpkgs overlay
      latest.firefox-nightly-bin
    ];
  };
}

