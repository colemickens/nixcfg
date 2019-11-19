#with (import (builtins.fetchTarball { url = "https://github.com/colemickens/nixpkgs/archive/cmpkgs.tar.gz"; }) {});
with (import /home/cole/code/nixpkgs {});
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
    (pkgs.writeScriptBin "azcopy" ''
      #!/usr/bin/env bash
      # "$azure-storage-azcopy}/bin/azure-storage-azcopy" "''${@}"
      /tmp/azcopy/azure-storage-azcopy/azure-storage-azcopy "''${@}"
    '')
    (pkgs.writeScriptBin "az" ''
      #!/usr/bin/env bash
      sudo docker run \
        -v /nix:/nix \
        -v /tmp/azure-cli:/tmp/azure-cli \
        -e "AZURE_CONFIG_DIR=/tmp/azure-cli" \
        -e "AZURE_USER=''${AZURE_USER:-"''${USER}"}" \
        -e "AZURE_STORAGE_CONNECTION_STRING=''${AZURE_STORAGE_CONNECTION_STRING}" \
        docker.io/microsoft/azure-cli:latest az "''${@}"
    '')
  ];

  AZURE_CONFIG_DIR="/tmp/azure-cli/.azure";
}