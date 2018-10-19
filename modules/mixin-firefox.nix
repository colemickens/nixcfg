{ config, lib, pkgs, ... }:

with lib;

{
  config = { 
    nixpkgs.overlays = [
      (import (builtins.fetchTarball {
        url = "https://github.com/mozilla/nixpkgs-mozilla/archive/65bfcb376612a2dc0439346e3af8dd0cd257a3de.tar.gz";
	sha256 = "0l0vqbbm93hnd1w0qkrfvg4yml7rq62jn554li05hlf90765fy50";
      }))
    ];
    environment.variables.MOZ_USE_XINPUT2 = "1";

    environment.systemPackages = with pkgs; [
      # firefox-nightly-bin from the mozilla-nixpkgs overlay
      latest.firefox-nightly-bin
    ];
  };
}

