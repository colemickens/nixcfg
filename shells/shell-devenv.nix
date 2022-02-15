{ inputs, system, minimalMkShell }:

let
  pkgs = import inputs.nixpkgs.legacyPackages.${system};
  rustPlatform = (pkgs.makeRustPlatform {
    inherit (inputs.fenix.packages.${system}.minimal) cargo rustc;
  });
in minimalMkShell pkgs.system { # TODO use something else for system?
  name = "devenv";
  hardeningDisable = [ "fortify" ];

  nativeBuildInputs = with pkgs; [
    (inputs.fenix.packages.${system}.complete.withComponents [
      "cargo"
      "clippy"
      "rust-src"
      "rustc"
      "rustfmt"
    ])
    # TODO: rust-overlay / fenix? ????? how to just get the very latest nightly?

    # deps
    freetype

    # native stuffs
    cmake
    ncurses
    pkgconfig
    lldb
    python3
    pcsclite

    # node
    nodejs
    yarn

    # golang
    go
    delve
    go-outline
    goimports
    godef
    #godoctor
    golint
    gopls
  ];

  buildInputs = with pkgs; [
    openssl
    clang
    gpgme libgpgerror libgit2 git # passrs
    dbus # passrs libsecret
    nettle # pass-rust (sequoia->nettle-sys)
  ];

  LIBCLANG_PATH="${pkgs.llvmPackages.libclang}/lib";
  RUST_BACKTRACE = 1;
}

/*
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
  ];

  buildInputs = with pkgs; [
    openssl
  ];

  RUST_BACKTRACE = 1;
}
*/
