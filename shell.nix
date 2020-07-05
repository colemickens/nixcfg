{ pkgs ? import /home/cole/code/nixpkgs/cmpkgs {}
, masterPkgs ? import /home/cole/code/nixpkgs/master {}
, cachixPkgs ? (import (builtins.fetchTarball { url = "https://cachix.org/api/v1/install"; }) {})
, ...
}:

pkgs.mkShell {
  nativeBuildInputs = []
  ++ (with cachixPkgs; [ cachix ])
  ++ (with pkgs; [
    bash
    cacert
    curl
    git
    jq
    mercurial
    nixFlakes
    nix-build-uncached
    nix-prefetch-git
    nettools
    openssh
    ripgrep
    rsync
  ]);
}
