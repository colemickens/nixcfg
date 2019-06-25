{ pkgs, lib, config, ... }:

with lib;

let
  firefoxNightlyLatest = pkgs.latest.firefox-nightly-bin;
  firefoxNightlyPinned = pkgs.lib.firefoxOverlay.firefoxVersion {
    name = "Firefox Nightly";
    version = "69.0a1";
    # last before: https://bugzilla.mozilla.org/show_bug.cgi?id=1512589
    #timestamp = "2018-12-06-09-26-19";
    # get timestamp from here:
    #  https://download.cdn.mozilla.net/pub/firefox/nightly/...
    timestamp = "2019-06-20-22-06-31";
    release = false;
  };
  #ff = firefoxNightlyPinned;
  ff = firefoxNightlyLatest;
  #ff = pkgs.firefox;
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
    environment.systemPackages = [ ff ];
  };
}

