let
  mkSystem = (import ../lib.nix {}).mkSystem;
  xeepOs = mkSystem rec {
    system = "x86_64-linux";
    nixoscfg = import ../machines/xeep.nix;
    nixpkgs = import ../nixpkgs/nixos-unstable;
    localnixpkgs = /root/code/nixpkgs; # if exists, used instead of the stable 'nixpkgs' ref
  };
in
  xeepOs.config.system.build.toplevel
