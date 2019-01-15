{ config, lib, pkgs, ... }:

with lib;

let
  firefoxNightlyLatest = pkgs.latest.firefox-nightly-bin;
  firefoxNightlyPinned = pkgs.lib.firefoxOverlay.firefoxVersion {
    name = "Firefox Nightly";
    version = "65.0a1";
    # last before: https://bugzilla.mozilla.org/show_bug.cgi?id=1512589
    timestamp = "2018-12-06-09-26-19";
    release = false;
  };
  firefoxNightly = firefoxNightlyLatest;
in
{
  config = { 
    environment.variables.MOZ_USE_XINPUT2 = "1";
    environment.systemPackages = with pkgs; [
      firefoxNightly
    ];
  };
}

