let
  pkgs = import (builtins.fetchTarball "https://github.com/nixos/nixpkgs/archive/nixos-unstable.tar.gz") {
    overlays = [ (import ./default.nix) ];
  };
in
  pkgs.colePackages

