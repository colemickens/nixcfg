#with (import (builtins.fetchTarball { url = "https://github.com/nixos/nixpkgs/archive/master.tar.gz"; }) {});
#with (import (builtins.fetchTarball { url = "https://github.com/colemickens/nixpkgs/archive/cmpkgs.tar.gz"; }) {});
with (import (builtins.fetchTarball { url = "https://github.com/colemickens/nixpkgs/archive/a59c8a555abca2aac2a8417abdb767c010af0ca4.tar.gz"; }) {});
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
