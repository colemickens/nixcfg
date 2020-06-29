let
  lib = import ../../lib.nix;
  system = lib.mkSystem {
    nixpkgs = lib.findImport "nixpkgs/cmpkgs";
    extraModules = [ ./configuration.nix ];
    system = "aarch64-linux";
  };
in
system.config.system.build.toplevel
