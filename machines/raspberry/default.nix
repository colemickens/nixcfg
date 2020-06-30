let
  lib = import ../../lib.nix;
  system = lib.mkSystem {
    nixpkgs = lib.findImport "nixpkgs/rpi";
    extraModules = [ ./configuration.nix ];
    system = "aarch64-linux";
    rev="git";
  };
in
system.config.system.build.toplevel
