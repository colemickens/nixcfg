let
  lib = import ../../lib.nix;
  image_plex = lib.mkSystem {
    nixpkgs = lib.findImport "nixpkgs" "cmpkgs";
    extraModules = [ ../../cloud/azure/image-azdev.nix ];
    system = "x86_64-linux";
  };
in
  image_plex.config.system.build.toplevel
