{}:

let
  lib = import ../lib.nix {};
  nixpkgs = "/etc/nixpkgs-cmpkgs";
  system = "x86_64-linux";

  result = (lib.mkSystem {
    inherit nixpkgs system;
    nixoscfg = ../modules/config-xeep.nix;
  }).config.system.build.toplevel;

in
  result

