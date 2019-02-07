let
  mkSystem = (import ../lib.nix {}).mkSystem;
  chimeraOs = mkSystem rec {
    system = "x86_64-linux";
    nixoscfg = import ../machines/chimera.nix;
    nixpkgs = import ../nixpkgs/nixos-unstable;
    localnixpkgs = /home/cole/code/nixpkgs-plex; # if exists, used instead of the stable 'nixpkgs' ref
  };
in
  chimeraOs.config.system.build.toplevel
