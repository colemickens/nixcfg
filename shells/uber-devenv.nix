let
  mozpkgs = builtins.fetchTarball { url = "https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz"; };
  pkgs = import (builtins.fetchTarball { url = "https://github.com/colemickens/nixpkgs/archive/cmpkgs.tar.gz"; }) {
    overlays = [
      (import "${mozpkgs}/rust-overlay.nix")
      (import "${mozpkgs}/rust-src-overlay.nix")
    ];
  };
in

pkgs.stdenv.mkDerivation {
  name = "devenv";

  nativeBuildInputs = with pkgs; [
    latest.rustChannels.stable.rust
    ncurses
    pkgconfig
    nodejs
  ];

  buildInputs = with pkgs; [
    openssl
  ];

  RUST_BACKTRACE = 1;
}
