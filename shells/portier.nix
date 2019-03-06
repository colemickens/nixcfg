let
  # TODO: pin this:
  pkgsUrl = "https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz";
  pkgs = import (builtins.fetchTarball pkgsUrl) {};
in
  pkgs.mkShell {
    name = "portier-env";
    buildInputs = with pkgs; [
      gcc
      sqlite
      pkg-config
      openssl
      gettext
    ];
  }

