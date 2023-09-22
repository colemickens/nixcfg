{ pkgs
, inputs
, ...
}:
let
  minimalMkShell = import ./_minimal.nix { inherit pkgs; };

  llvmPackages = pkgs.llvmPackages_13;

  gstreamerPath = ""
    + ":" + "${pkgs.gst_all_1.gst-plugins-base}/lib/gstreamer-1.0"
    + ":" + "${pkgs.gst_all_1.gst-plugins-good}/lib/gstreamer-1.0"
    + ":" + "${pkgs.gst_all_1.gst-plugins-bad}/lib/gstreamer-1.0"
    + ":" + "${pkgs.gst_all_1.gst-plugins-ugly}/lib/gstreamer-1.0"
  ;

  _rustBuild = (inputs.fenix.packages.${pkgs.stdenv.hostPlatform.system}.latest.withComponents [
    "cargo"
    "clippy"
    "rust-src"
    "rustc"
    "rustfmt"
  ]);
in
minimalMkShell {
  name = "dev";
  hardeningDisable = [ "fortify" ];

  shellHook = ''
    exec nu
  '';

  LD_LIBRARY_PATH = "${pkgs.libglvnd}/lib";
  LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";
  RUST_BACKTRACE = 1;
  GST_PLUGIN_SYSTEM_PATH = gstreamerPath;

  nativeBuildInputs = with pkgs; [
    _rustBuild

    inputs.fenix.packages.${pkgs.stdenv.hostPlatform.system}.rust-analyzer

    inputs.nix-eval-jobs.outputs.packages.${pkgs.stdenv.hostPlatform.system}.default

    nix

    ## nix lsp
    rnix-lsp
    nil

    ## nix space usage / visualizers
    nix-du
    nix-tree

    # nix formatters
    nixpkgs-fmt
    nixfmt
    alejandra

    ## tools
    lldb

    ## nodejs
    nodejs
    yarn

    ## golang
    go
    go-outline
    gotools
    godef
    gopls

    # generic build essentials
    pkg-config
    cmake
    gnumake
    nasm
    perl

    # json tools
    gron

    gst_all_1.gstreamer
  ];

  buildInputs = with pkgs; [
    llvmPackages.libclang
    llvmPackages.libclang.lib
    pipewire
    freetype
    ncurses
    pcsclite
    openssl
    clang
    libusb1
    gpgme
    libgpg-error
    libgit2
    git # passrs
    dbus # passrs libsecret
    nettle # pass-rust (sequoia->nettle-sys)
    gst_all_1.gstreamer
    libnice
    pango
    cairo
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav

    crate2nix

    glslang
    gtk3
    gtk4

    atk # sirula
    gdk-pixbuf # sirula
    udev
    mesa
    libinput # Anodium
    seatd # Anodium
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXi # Anodium
    libxkbcommon
    wayland
    wayland-protocols # wezterm
    fontconfig
    libglvnd
    opencv
    ffmpeg
    egl-wayland # wezterm
    xorg.libX11
    xorg.libxcb
    xorg.xcbutil # wezterm
    xorg.xcbproto
    xorg.xcbutil
    xorg.xcbutilwm # wezterm
    xorg.xcbutilkeysyms
    xorg.xcbutilimage # wezterm
  ];
}
