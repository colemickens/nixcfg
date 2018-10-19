{}:

let
  lib = import ../lib.nix {};
  nixpkgs = "/etc/nixpkgs-chimera";
  system = "x86_64-linux";

  chimera = {
    toplevel = (lib.mkSystem {
      inherit nixpkgs system;
      nixoscfg = ./configuration.nix;
    }).config.system.build.toplevel;
  };

in
  chimera

