{ inputs, system, minimalMkShell }:

let
  pkgs = inputs.nixpkgs.legacyPackages.${system};
  rustPlatform = (pkgs.makeRustPlatform {
    inherit (inputs.fenix.packages.${system}.minimal) cargo rustc;
  });

  x86_only = (with pkgs; [
    # delve (should be okay now...)
  ]);
  extraPkgs =
    if system == "x86_64-linux" then x86_only
    else (with pkgs; [
      # more here?
      delve
    ]);
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
    bacon
    cargo-watch
    rust-analyzer
    lldb_13
    #vscode-extensions.vadimcn.vscode-lldb.adapter
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
    go-outline
    goimports
    godef
    #godoctor
    golint
    gopls
  ] ++ extraPkgs;
  #] ++ (if !fullPkgs then [] else [
  #  zellij # config?
  #  helix # config?
  #]);

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
