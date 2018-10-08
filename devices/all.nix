{ nixpkgs ? <nixpkgs>, ... }:

let
  nixos = import "${nixpkgs}/nixos";
  mkMachine = c: (nixos { configuration = c; }).system;
  pkgs = import nixpkgs {};
  patches = import ./xeep/patches.nix { inherit pkgs; };
  result = {
    xeep    = (mkMachine { imports = [ ./xeep/default.nix {}]; });
    xeepV3 = (mkMachine { imports = [ ./xeep/default.nix {} ]; xeep.kernelPatches = [ patches.trackpadPatchV3 ]; });
    xeepV4 = (mkMachine { imports = [ ./xeep/default.nix {} ]; xeep.kernelPatches = [ patches.trackpadPatchV4 ]; });
    #chimera = (mkMachine ./chimera/default.nix);
    #packet-kube = (mkMachine ./packet-kube/default.nix); # TODO: this needs a custom nixpkgs!
  };
in
  result

