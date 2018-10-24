with import (if builtins.pathExists "/etc/nixpkgs" then "/etc/nixpkgs" else <nixpkgs>) {
  overlays = [
    (import (builtins.fetchTarball {
      url = "https://github.com/stesie/azure-cli-nix/archive/21d92db4d81af549784c8545c40f7a1abdb9c7dd.tar.gz";
      sha256 = "1s9g9g2vifhba0i99dlhppafbiqi9gdyfna2mpgnpkcdp2z3gj2q";
    }))
  ];
};

stdenv.mkDerivation rec {
  name = "azure-nix-shell";
  buildInputs = [ python36Packages.azure-cli jq coreutils ];
}

