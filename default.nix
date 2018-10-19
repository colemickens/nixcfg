let
  lib = import ./lib.nix {};

  # xeep
  # used with nixpkgs 'cmpkgs' (and currently 'sway')
  outputs = {
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

    pktkube = (if ! builtins.pathExists "/etc/nixos/packet" then null else
    (lib.mkSystem {
      nixpkgs = "/etc/nixpkgs-kata";
      nixoscfg = ./modules/config-pktkube.nix;
      system = "x86_64-linux";
    }).config.system.build.toplevel);
  };

in
  outputs

