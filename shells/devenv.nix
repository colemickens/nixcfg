{ inputs, system, minimalMkShell }:

let
  pkgs = inputs.nixpkgs.legacyPackages.${system};
  llvmPackages = pkgs.llvmPackages_13;

  gstreamerPath = ""
    + ":" + "${pkgs.gst_all_1.gst-plugins-base}/lib/gstreamer-1.0"
    + ":" + "${pkgs.gst_all_1.gst-plugins-good}/lib/gstreamer-1.0"
    + ":" + "${pkgs.gst_all_1.gst-plugins-bad}/lib/gstreamer-1.0"
    + ":" + "${pkgs.gst_all_1.gst-plugins-ugly}/lib/gstreamer-1.0"
  ;
in minimalMkShell pkgs.system { # TODO use something else for system?
  name = "devenv";
  hardeningDisable = [ "fortify" ];

  LIBCLANG_PATH="${llvmPackages.libclang}/lib";
  RUST_BACKTRACE = 1;
  GST_PLUGIN_SYSTEM_PATH = gstreamerPath;

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
    /*golang*/ go go-outline gotools godef /*golint*/ gopls

    pkg-config
      
    /* coreboot */
    # flashrom # use nixos module for udev rules
    gst_all_1.gstreamer
    # gst_all_1
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
  ];

  buildInputs = with pkgs; [
    freetype
    ncurses
    pcsclite
    openssl
    clang
    libusb
    gpgme libgpgerror libgit2 git # passrs
    dbus # passrs libsecret
    nettle # pass-rust (sequoia->nettle-sys)
    gst_all_1.gstreamer
    # gst_all_1
    libnice
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
          
    udev mesa libinput # Anodium
    xorg.libXcursor xorg.libXrandr xorg.libXi # Anodium
    libxkbcommon wayland wayland-protocols # wezterm
    fontconfig libglvnd egl-wayland # wezterm
    xorg.libX11 xorg.libxcb xorg.xcbutil # wezterm
    xorg.xcbproto xorg.xcbutil xorg.xcbutilwm  # wezterm
    xorg.xcbutilkeysyms xorg.xcbutilimage # wezterm
  ];
}
