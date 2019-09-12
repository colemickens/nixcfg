{ pkgs, lib, config, ... }:

with lib;

let
  stable = pkgs.firefox;
  nightlyLatest = pkgs.latest.firefox-nightly-bin;
  nightlyPinned = pkgs.lib.firefoxOverlay.firefoxVersion {
    # get timestamp from here: https://download.cdn.mozilla.net/pub/firefox/nightly/...
    name = "Firefox Nightly";
    version = "70.0a1";
    timestamp = "2019-08-15-19-35-05";
    release = false;
  };
  # we don't have our hacked up nixpkgs-mozilla overlay on packet
  # so just build with the last build that can actually be retrieved
  nightlyBuild =
    if lib.pathExists "/etc/nixos/packet/userdata.nix"
      then nightlyPinned
      else nightlyLatest;
  nightly = pkgs.writeShellScriptBin "firefox-nightly" ''
    exec ${nightlyBuild}/bin/firefox "''${@}"
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
    environment.systemPackages = [ stable nightly ];
  };
}

