with (import (builtins.fetchTarball { url = "https://github.com/nixos/nixpkgs/archive/nixos-unstable.tar.gz"; }) {});
stdenv.mkDerivation {
  name = "nixcfg-azure-devenv";

  nativeBuildInputs = [
    azure-cli
    bash
    cacert
    azure-storage-azcopy
  ];

  AZURE_CONFIG_DIR="/tmp/azure-cli/.azure";
}
