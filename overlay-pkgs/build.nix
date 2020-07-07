let
  pkgs = import (import ../.imports/nixpkgs/cmpkgs) {
    overlays = [ (import ./default.nix) ];
  };
in
  pkgs.colePackages

