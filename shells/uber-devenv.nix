let
  mozpkgs = builtins.fetchTarball { url = "https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz"; };
  pkgs = import ../../nixpkgs/cmpkgs {
    overlays = [
      (import "${mozpkgs}/rust-overlay.nix")
      (import "${mozpkgs}/rust-src-overlay.nix")
    ];
  };
in

pkgs.stdenv.mkDerivation {
  name = "devenv";

  nativeBuildInputs = with pkgs; [
    cmake
    freetype
    latest.rustChannels.beta.rust
    rust-analyzer
    ncurses
    pkgconfig
    nodejs
    go
    lldb
    python3
    pcsclite
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
