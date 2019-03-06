let
  # TODO: pin this:
  pkgsUrl = "https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz";
  pkgs = import (builtins.fetchTarball pkgsUrl) {};
in
  pkgs.mkShell {
    name = "dex-env";
    buildInputs = with pkgs; [
      go
      gcc
      sqlite
    ];

    GOPATH = "/tmp/gopath";
  }

