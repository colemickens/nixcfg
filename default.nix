let
  lib = import ./lib.nix {};

  # xeep
  # used with nixpkgs 'cmpkgs'
  xeep = (lib.mkSystem {
    nixpkgs = "/etc/nixpkgs-cmpkgs";
    nixoscfg = ./modules/config-xeep.nix;
    system = "x86_64-linux";
  }).config.system.build.toplevel;

  # chimera
  # used with nixpkgs `chimera` branch until plex is merged
  # and we can go back to regular cmpkgs
  chimera = (lib.mkSystem {
    nixpkgs = "/etc/nixpkgs-chimera";
    nixoscfg = ./modules/config-chimera.nix;
    system = "x86_64-linux";
  }).config.system.build.toplevel;

  # packet vm w/ kube config (used with `kata` nixpkgs branch)
  pktkube = (lib.mkSystem {
    nixpkgs = "/etc/nixpkgs-kata";
    nixoscfg = ./modules/config-pktkube.nix;
    system = "x86_64-linux";
  }).config.system.build.toplevel;


in
  {
    inherit xeep;
    inherit chimera;
    #inherit pktkube;
  }

