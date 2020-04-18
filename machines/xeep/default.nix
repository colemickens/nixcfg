let
  lib = import ../../lib.nix;
  system = lib.mkSystem {
    nixpkgs = lib.findNixpkgs "cmpkgs";
    extraModules = [
      ./base.nix
    ];
    system = "x86_64-linux";
  };
in
system.config.system.build.toplevel
