let
  mkSystem = (import ../lib.nix {}).mkSystem;
  goonhabOs = mkSystem rec {
    system = "x86_64-linux";
    nixoscfg = import ../machines/goodhab.nix;
    nixpkgs = import ../nixpkgs/nixos-unstable-openhab;
    localnixpkgs = /home/cole/code/nixpkgs-openhab; # if exists, used instead of the stable 'nixpkgs' ref
  };
in
  goonhabOs.config.system.build.toplevel
