{ pkgs, lib, config, ... }:

with lib;

let
  firefoxNightlyNow = pkgs.latest.firefox-nightly-bin;
  firefoxNightlyPin = pkgs.lib.firefoxOverlay.firefoxVersion {
    # get timestamp from here: https://download.cdn.mozilla.net/pub/firefox/nightly/...
    name = "Firefox Nightly";
    version = "69.0a1";
    timestamp = "2019-07-05-16-10-30";
    release = false;
  };
  firefoxStable = pkgs.firefox;
  firefoxNightlyUnwrapped = firefoxNightlyNow;
  firefoxNightly = pkgs.writeShellScriptBin "firefox-nightly" ''
    exec ${firefoxNightlyUnwrapped}/bin/firefox "''${@}"
  '';
  overlay = (import ../lib.nix {}).overlay;
in
{
  config = {
    nixpkgs = {
      config.allowUnfree = true;
      overlays = [
        (overlay "nixpkgs-mozilla" "https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz")
      ];
      config.firefox.enableFXCastBridge = true;
    };
    environment.variables.MOZ_USE_XINPUT2 = "1";
    environment.variables.MOZ_ENABLE_WAYLAND = "1";
    environment.systemPackages = [
      firefoxStable
      firefoxNightly
    ];
  };
}

