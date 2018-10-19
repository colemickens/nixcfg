let
  lib = import ./lib.nix {};

  x = lib.mkSystem {
    nixpkgs = "/etc/nixpkgs-cmpkgs";
    nixoscfg = ./modules/config-xeep.nix;
    system = "x86_64-linux";
  };

  #c = import ./outputs/chimera-toplevel.nix {};

in
  [
    x
    # c
  ]
