{ pkgs ? import /home/cole/code/nixpkgs/cmpkgs {}
, masterPkgs ? import /home/cole/code/nixpkgs/master {}
, cachixPkgs ? (import (builtins.fetchTarball { url = "https://cachix.org/api/v1/install"; }) {})
, ...
}:

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    masterPkgs.nixFlakes
    cachixPkgs.cachix
    bash
    cacert
    curl
    git
    jq
    mercurial
    nix-build-uncached
    nix-prefetch-git
    nettools
    openssh
    ripgrep
    rsync
  ];
}
