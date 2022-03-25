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

    pkg-config
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
      
    udev mesa libinput # Anodium
    xorg.libXcursor xorg.libXrandr xorg.libXi # Anodium
    libxkbcommon wayland wayland-protocols # wezterm
    fontconfig libglvnd egl-wayland # wezterm
    xorg.libX11 xorg.libxcb xorg.xcbutil # wezterm
    xorg.xcbproto xorg.xcbutil xorg.xcbutilwm  # wezterm
    xorg.xcbutilkeysyms xorg.xcbutilimage # wezterm
  ];
}
