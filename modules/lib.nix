{ ... }:

let
  lib = {
    mkSystem = { nixpkgs, nixoscfg, system, extraModules ? []}:
      let
        pkgs = import nixpkgs {
          inherit system;
          inherit (machine.config.nixpkgs) config overlays;
        };
        machine = import "${nixpkgs}/nixos/lib/eval-config.nix" {
          inherit (pkgs) system;
          inherit pkgs;
          modules = [ nixoscfg ] ++ extraModules;
        };
      in
        machine;
  };
in
  lib

