let
  lib = import ./lib.nix {};

  # xeep
  xeep = (lib.mkSystem {
    nixpkgs = "https://github.com/colemickens/nixpkgs/archive/cmpkgs.tar.gz";
    nixoscfg = ./modules/config-xeep.nix;
    system = "x86_64-linux";
  }).config.system.build.toplevel;

  # chimera
  chimera = (lib.mkSystem {
    nixpkgs = "https://github.com/colemickens/nixpkgs/archive/plex.tar.gz";
    nixoscfg = ./modules/config-chimera.nix;
    system = "x86_64-linux";
  }).config.system.build.toplevel;

  # packet vm should use upstream nixpkgs channels
  pktkube = (lib.mkSystem {
    nixpkgs = "https://github.com/nixos/nixpkgs-channels/archive/nixos-unstable.tar.gz";
    nixoscfg = ./modules/config-pktkube.nix;
    system = "x86_64-linux";
  }).config.system.build.toplevel;

in
  {
    inherit xeep;
    inherit chimera;
    inherit pktkube;
  }

