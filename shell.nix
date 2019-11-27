with (import /home/cole/code/nixpkgs {});
let
  azcopypkgs = (import (builtins.fetchTarball { url = "https://github.com/colemickens/nixpkgs/archive/cff97b9b40bbafc0beee92e9da81eb710640fb83.tar.gz"; }) {});
in
stdenv.mkDerivation {
  name = "nixcfg-devenv";

  nativeBuildInputs = []
  #++ (with azcopypkgs; [ azure-cli azure-storage-azcopy  ])
  ++ [
    bash
    cacert
    cachix
    curl
    git
    mercurial
    nix
    openssh
    ripgrep
    
    python3

    # gcpdrivebridgeGuest is not running.
    google-cloud-sdk
  ];
}
