let
  mkSystem = (import ../lib.nix {}).mkSystem;
  slinuxOs = mkSystem rec {
    system = "x86_64-linux";
    nixoscfg = import ../machines/slinux.nix;
    nixpkgs = import ../nixpkgs/nixos-unstable;
    localnixpkgs = /home/cole/code/nixpkgs; # if exists, used instead of the stable 'nixpkgs' ref
  };
in
  slinuxOs.config.system.build.toplevel
