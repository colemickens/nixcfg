{ ... }:

let
  nixcfg = "/etc/nixcfg";

  nixpkgs-cmpkgs  = "/etc/nixpkgs-cmpkgs";
  nixpkgs-chimera = "/etc/nixpkgs-chimera";
  nixpkgs-kata = "/etc/nixpkgs-kata";

  result = {
    xeep    = (import ./modules/device-xeep-all.nix    { nixpkgs = nixpkgs-cmpkgs; });
    chimera = (import ./modules/device-chimera-all.nix { nixpkgs = nixpkgs-chimera; });
    # hvbldr  = (import ./modules/device-hvbldr-all.nix  { nixpkgs = nixpkgs-cmpkgs; });
  }
  // (if ! builtins.pathExists "/etc/nixos/packet" then null else
  {
    # pktkube = (import ./modules/devices-pktkube-all.nix { nixpkgs = nixpkgs-kata; });
  });

in
  result
