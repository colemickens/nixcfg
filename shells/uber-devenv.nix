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
    latest.rustChannels.nightly.rust
    ncurses
    pkgconfig
    nodejs
    go
    lldb
    python3
  ];

  buildInputs = with pkgs; [
    openssl
    gpgme libgpgerror libgit2 git # passrs
    dbus # passrs libsecret
  ];

  RUST_BACKTRACE = 1;
}
