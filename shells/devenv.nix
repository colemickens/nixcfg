{ inputs, system, minimalMkShell }:

let
  pkgs = inputs.nixpkgs.legacyPackages.${system};
  llvmPackages = pkgs.llvmPackages_13;

in minimalMkShell pkgs.system { # TODO use something else for system?
  name = "devenv";
  hardeningDisable = [ "fortify" ];

  LIBCLANG_PATH="${llvmPackages.libclang}/lib";
  RUST_BACKTRACE = 1;

  nativeBuildInputs = with pkgs; [
    (inputs.fenix.packages.${system}.latest.withComponents [
      "cargo"
      "clippy"
      "rust-src"
      "rustc"
      "rustfmt"
    ])
    inputs.fenix.packages.${system}.rust-analyzer
    cargo-watch bacon
    llvmPackages.lldb
    rnix-lsp

    /*tools */ cmake pkgconfig lldb python3
    /*nodejs*/ nodejs yarn
    /*golang*/ go go-outline gotools godef golint gopls
  ];

  buildInputs = with pkgs; [
    freetype
    ncurses
    pcsclite
    openssl
    clang
    gpgme libgpgerror libgit2 git # passrs
    dbus # passrs libsecret
    nettle # pass-rust (sequoia->nettle-sys)
  ];
}
