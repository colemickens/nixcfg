let
  lib = import ../../lib.nix;
  image_plex = lib.mkSystem {
    nixpkgs = lib.findImport "nixpkgs/nixos-unstable";
    extraModules = [ ./configuration.nix ];
    system = "x86_64-linux";
  };
in
  image_plex.config.system.build.toplevel
