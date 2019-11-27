with (import (builtins.fetchTarball { url = "https://github.com/nixos/nixpkgs/archive/master.tar.gz"; }) {});
stdenv.mkDerivation {
  name = "nixcfg-azure-devenv";

  nativeBuildInputs = [
    azure-cli
    bash
    cacert
  ];

  AZURE_CONFIG_DIR="/tmp/azure-cli/.azure";
}
