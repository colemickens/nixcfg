let
  mkSystem = (import ../lib.nix {}).mkSystem;
  veraOs = mkSystem rec {
    system = "x86_64-linux";
    nixoscfg = import ../machines/vera.nix;
    nixpkgs = import ../nixpkgs/nixos-unstable;
    localnixpkgs = /home/cole/code/nixpkgs;
  };
in
  veraOs.config.system.build.toplevel
