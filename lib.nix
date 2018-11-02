{ ... }:

let
  lib = {
    mkSystem = { nixpkgs, fallback, nixoscfg, system, extraModules ? []}:
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

    mkHypervImage = { nixpkgs, nixoscfg, system, extraModules ? []}:
      let
        extraModules = extraModules ++ [ "${nixpkgs}/nixos/modules/virtualization/hyperv-image.nix" ];
      in
        lib.mkSystem {
          inherit nixpkgs nixoscfg system extraModules;
        };
  };
in
  lib

