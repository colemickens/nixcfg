{ pkgs, inputs, ... }:

let
  lib = pkgs.lib;
  minimalMkShell = import ./_minimal.nix { inherit pkgs; };

  llvmPackages = pkgs.llvmPackages_20;

  gstreamerPath =
    ""
    + ":"
    + "${pkgs.gst_all_1.gst-plugins-base}/lib/gstreamer-1.0"
    + ":"
    + "${pkgs.gst_all_1.gst-plugins-good}/lib/gstreamer-1.0"
    + ":"
    + "${pkgs.gst_all_1.gst-plugins-bad}/lib/gstreamer-1.0"
    + ":"
    + "${pkgs.gst_all_1.gst-plugins-ugly}/lib/gstreamer-1.0";

  _rustBuildOxalica = inputs.rust-overlay.packages.${pkgs.stdenv.hostPlatform.system}.rust.override {
    extensions = [
      "rust-src"
      "rust-analyzer"
      "clippy"
    ];
  };
  _rustBuild = _rustBuildOxalica;
in
# _rustBuild = _rustBuildFenix;
minimalMkShell rec {
  name = "cole-nixcfg-devenv";
  hardeningDisable = [ "fortify" ];

  shellHook = ''
    exec nu
  '';

  LD_LIBRARY_PATH = "${lib.makeLibraryPath buildInputs}";
  LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";
  RUST_BACKTRACE = 1;
  GST_PLUGIN_SYSTEM_PATH = gstreamerPath;

  nativeBuildInputs = with pkgs; [
    _rustBuild
    llvmPackages.lldb

    # inputs.nix-eval-jobs.outputs.packages.${pkgs.stdenv.hostPlatform.system}.default

    nix

    ## nix lsp
    # rnix-lsp # pulls in old nix (CVE)
    nil
    nixd

    ## nix space usage / visualizers
    # nix-du # TOOD(colemickens): broken 2024-07-30, restore later?
    nix-tree

    # nix formatters
    nixfmt
    alejandra

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

    protobuf

    # not a good sign
    dos2unix

    wayland-scanner
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
