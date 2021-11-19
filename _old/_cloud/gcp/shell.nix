let
  pkgs = import /home/cole/code/nixpkgs {};
in
pkgs.stdenv.mkDerivation {
  name = "nixcfg-devenv";

  nativeBuildInputs = []
  ++ (with pkgs; [
    google-cloud-sdk

    bash
    cacert
    curl
    git
    mercurial
    nix
    openssh
    ripgrep
  ]);
}
