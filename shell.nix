with (import (builtins.fetchTarball { url = "https://github.com/colemickens/nixpkgs/archive/cmpkgs.tar.gz"; }) {});
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
  ];

  buildInputs = [
    openssl
  ];
}
