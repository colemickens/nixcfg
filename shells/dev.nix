{ pkgs
, inputs
, ...
}:
let
  minimalMkShell = import ./_minimal.nix { inherit pkgs; };

  # 16 is broken: https://github.com/NixOS/nixpkgs/issues/244609
  # llvmPackages = pkgs.llvmPackages_16;
  llvmPackages = pkgs.llvmPackages_15;

  gstreamerPath = ""
    + ":" + "${pkgs.gst_all_1.gst-plugins-base}/lib/gstreamer-1.0"
    + ":" + "${pkgs.gst_all_1.gst-plugins-good}/lib/gstreamer-1.0"
    + ":" + "${pkgs.gst_all_1.gst-plugins-bad}/lib/gstreamer-1.0"
    + ":" + "${pkgs.gst_all_1.gst-plugins-ugly}/lib/gstreamer-1.0"
  ;

  _rustBuildFenix = (inputs.fenix.packages.${pkgs.stdenv.hostPlatform.system}.latest.withComponents [
    "cargo"
    "clippy"
    "rust-src"
    "rustc"
    "rustfmt"
    "rust-analyzer"
  ]);

  _rustBuildOxalica = inputs.rust-overlay.packages.${pkgs.stdenv.hostPlatform.system}.rust.override {
    extensions = [ "rust-src" "rust-analyzer" "clippy" ];
  };

  # so far I can't tell a big difference...
  _rustBuild = _rustBuildOxalica;
  # _rustBuild = _rustBuildFenix;

in
minimalMkShell {
  name = "cole-nixcfg-dev";
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
    llvmPackages.lldb

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

    # not a good sign
    dos2unix
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
