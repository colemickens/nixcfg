{ pkgs, lib, config, ... }:

with lib;

let
  overlay = (import ../lib.nix {}).overlay;

  stable = pkgs.firefox;
  nightly = pkgs.writeShellScriptBin "firefox-nightly" ''
    exec ${pkgs.latest.firefox-nightly-bin}/bin/firefox "''${@}"
  '';

  useNightly = true;
  firefoxPkgs = [ stable ] ++ lib.optionals useNightly [ nightly ];
in
{
  config = {
    nixpkgs = {
      config.allowUnfree = true;
      overlays = if useNightly then [ (overlay "nixpkgs-mozilla") ] else [];
      config.firefox.enableFXCastBridge = true;
    };
    environment.variables.MOZ_USE_XINPUT2 = "1";
    environment.variables.MOZ_ENABLE_WAYLAND = "1";
    environment.systemPackages = firefoxPkgs;
  };
}

