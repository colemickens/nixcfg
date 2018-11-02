let
  lib = import ./lib.nix {};

  # xeep
  # used with nixpkgs 'cmpkgs'
  xeep = (lib.mkSystem {
    nixpkgs = "/etc/nixpkgs-cmpkgs";
    fallback = "https://github.com/colemickens/nixpkgs/archive/cmpkgs.tar.gz";
    nixoscfg = ./modules/config-xeep.nix;
    system = "x86_64-linux";
  }).config.system.build.toplevel;

  # chimera
  # used with nixpkgs `chimera` branch until plex is merged
  # and we can go back to regular cmpkgs
  chimera = (lib.mkSystem {
    nixpkgs = "/etc/nixpkgs-plex";
    fallback = "https://github.com/colemickens/nixpkgs/archive/plex.tar.gz";
    nixoscfg = ./modules/config-chimera.nix;
    system = "x86_64-linux";
  }).config.system.build.toplevel;

  # packet vm w/ kube config (used with `kata` nixpkgs branch)
  pktkube = (lib.mkSystem {
    nixpkgs = "/etc/nixpkgs-kata";
    fallback = "https://github.com/colemickens/nixpkgs/archive/kata.tar.gz";
    nixoscfg = ./modules/config-pktkube.nix;
    system = "x86_64-linux";
  }).config.system.build.toplevel;

in
  {
    inherit xeep;
    inherit chimera;

    # TODO: kube-router is broken in the `kata` branch
    # inherit pktkube;
  }

