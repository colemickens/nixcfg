{ nixpkgs }:

let
  lib = import ../../lib.nix {};
  system = "x86_64-linux";

  result = {
    machine = (lib.mkSystem {
      inherit nixpkgs system;
      nixoscfg = ./configuration.nix;
    }).config.system.build.toplevel;
  };

in
  result

