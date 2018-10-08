{ nixpkgs ? <nixpkgs>, ... }:

let
  nixos = import "${nixpkgs}/nixos";
  mkMachine = c: (nixos { configuration = c; }).system;
  mkMachine2 = c: (import "${nixpkgs}/nixos/lib/eval-config.nix" {
    inherit (pkgs) system;
    modules = [ c ];
  }).config.system.build.toplevel;
  pkgs = import nixpkgs {};
  patches = import ./xeep/patches.nix { inherit pkgs; };
  result = {
    xeel   = (mkMachine ./xeep/default.nix);
    xeep   = (mkMachine { imports = [ ./xeep/default.nix {}]; });
    xeepV3 = (mkMachine { imports = [ ./xeep/default.nix {} ]; xeep.kernelPatches = [ patches.trackpadPatchV3 ]; });
    xeepV4 = (mkMachine { imports = [ ./xeep/default.nix {} ]; xeep.kernelPatches = [ patches.trackpadPatchV4 ]; });

    alt_xeel   = (mkMachine2 ./xeep/default.nix);
    alt_xeep   = (mkMachine2 { imports = [ ./xeep/default.nix {} ]; });
    alt_xeepV3 = (mkMachine2 { imports = [ ./xeep/default.nix {} ]; xeep.kernelPatches = [ patches.trackpadPatchV3 ]; });
    alt_xeepV4 = (mkMachine2 { imports = [ ./xeep/default.nix {} ]; xeep.kernelPatches = [ patches.trackpadPatchV4 ]; });

    #chimera = (mkMachine ./chimera/default.nix);
    #packet-kube = (mkMachine ./packet-kube/default.nix); # TODO: this needs a custom nixpkgs!
  };
in
  result

