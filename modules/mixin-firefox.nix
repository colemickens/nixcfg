{ pkgs, lib, config, ... }:

with lib;

let
  overlay = (import ../lib.nix {}).overlay;

  stable = pkgs.firefox;
  nightly = pkgs.writeShellScriptBin "firefox-nightly" ''
    exec ${pkgs.latest.firefox-nightly-bin}/bin/firefox "''${@}"
  '';
  
  # TODO: remove when firefox overlay is fixed
  safeToUseNightly = lib.pathExists ../../overlays/nixpkgs-mozilla/default.nix;
  firefoxPkgs = [ stable ] ++ (lib.optionals safeToUseNightly [ nightly ]);
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
    environment.systemPackages = firefoxPkgs;
  };
}

