with (import (builtins.fetchTarball { url = "https://github.com/nixos/nixpkgs/archive/nixos-unstable.tar.gz"; }) {});
stdenv.mkDerivation {
  name = "nixcfg-devenv";

  nativeBuildInputs = [
    bash
    cacert
    cachix
    curl
    mercurial
    nix
    openssh
    gitAndTools.gitFull
    gitAndTools.hub
    ripgrep

    # gcpdrivebridge
    google-cloud-sdk
    
    # azplex
    azure-storage-azcopy # = pkgs.callPackage ./pkgs/azure-storage-azcopy {};
  ];

  buildInputs = [
    openssl
  ];
}
