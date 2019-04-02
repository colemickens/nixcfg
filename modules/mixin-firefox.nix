{ config, lib, pkgs, ... }:

with lib;

let
  firefoxNightlyLatest = pkgs.latest.firefox-nightly-bin;
  firefoxNightlyPinned = pkgs.lib.firefoxOverlay.firefoxVersion {
    name = "Firefox Nightly";
    version = "68.0a1";
    # last before: https://bugzilla.mozilla.org/show_bug.cgi?id=1512589
    #timestamp = "2018-12-06-09-26-19";
    timestamp = "2019-03-28-13-14-10";
    release = false;
  };
  firefoxNightly = firefoxNightlyPinned;
  overlay = (import ../lib.nix {}).overlay;
in
{
  config = {
    nixpkgs = {
      config.allowUnfree = true;
      overlays = [
        (overlay
          "nixpkgs-mozilla"
          "https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz")
      ];
      config.firefox.enableFXCastBridge = true;
    };
    environment.variables.MOZ_USE_XINPUT2 = "1";
    environment.variables.MOZ_ENABLE_WAYLAND = "1";
    environment.systemPackages = with pkgs; [
      firefoxNightly
    ];
  };
}

