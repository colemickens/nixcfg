{ pkgs, inputs }@args:

let
  llvmPackages = pkgs.llvmPackages_13;

  # gst_new = gst_all_1.override{
  #   src = "";
  # };

  # TODO: add pipewire for 'pipewiresrc'

  gst-new-src = pkgs.fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "gstreamer";
    repo = "gstreamer";
    rev = "42838c3b9efb1c726f6cba4e25ecf8d47f88c827";
    hash = "sha256-nVOG1ToAVLIk6AgxFcvMvBdeX3qrPHQUdfzk3MbZkV0=";
  };
  gst-overlay =
    (final: prev: {
      # gst_all_1 = {
      #   gstreamer = prev.gst_all_1.gstreamer.overrideAttrs (old: rec {
      #     version = "1.21.0.1";
      #     src = gst-new-src;
      #     sourceRoot = "${src.name}/subprojects/gstreamer";
      #   });
      #   gst-plugins-base = prev.gst_all_1.gst-plugins-base.overrideAttrs (old: rec {
      #     version = "1.21.0.1";
      #     src = gst-new-src;
      #     sourceRoot = "${src.name}/subprojects/gst-plugins-base";
      #     buildInputs = old.buildInputs ++ [ prev.xorg.libXi ];
      #   });
      #   gst-plugins-good = prev.gst_all_1.gst-plugins-good.overrideAttrs (old: rec {
      #     version = "1.21.0.1";
      #     src = gst-new-src;
      #     sourceRoot = "${src.name}/subprojects/gst-plugins-good";
      #   });
      #   gst-plugins-bad = prev.gst_all_1.gst-plugins-bad.overrideAttrs (old: rec {
      #     version = "1.21.0.1";
      #     src = gst-new-src;
      #     sourceRoot = "${src.name}/subprojects/gst-plugins-bad";
      #     buildInputs = old.buildInputs ++ (with prev; [
      #       gtk3
      #     ]);
      #     mesonFlags = old.mesonFlags ++ [
      #       "-Damfcodec=disabled"
      #       "-Ddirectshow=disabled"
      #       "-Ddirectfb=disabled"
      #     ];
      #   });
      #   gst-plugins-ugly = prev.gst_all_1.gst-plugins-ugly.overrideAttrs (old: rec {
      #     version = "1.21.0.1";
      #     src = gst-new-src;
      #     sourceRoot = "${src.name}/subprojects/gst-plugins-ugly";
      #   });
      #   gst-libav = prev.gst_all_1.gst-libav.overrideAttrs (old: rec {
      #     version = "1.21.0.1";
      #     src = gst-new-src;
      #     sourceRoot = "${src.name}/subprojects/gst-libav";
      #   });
        # gst-omx = prev.gst_all_1.gst-omx.overrideAttrs (old: rec {
        #   version = "1.21.0.1";
        #   src = gst-new-src;
        #   sourceRoot = "${src.name}/subprojects/gst-omx";
        # });
      # };
    });

  gstreamerPath = ""
    + ":" + "${pkgs.gst_all_1.gst-plugins-base}/lib/gstreamer-1.0"
    + ":" + "${pkgs.gst_all_1.gst-plugins-good}/lib/gstreamer-1.0"
    + ":" + "${pkgs.gst_all_1.gst-plugins-bad}/lib/gstreamer-1.0"
    + ":" + "${pkgs.gst_all_1.gst-plugins-ugly}/lib/gstreamer-1.0"
    + ":" + "${pkgs.gst_all_1.gst-libav}/lib/gstreamer-1.0"
    # + ":" + "${pkgs.gst_all_1.gst-omx}/lib/gstreamer-1.0"
  ;
  pkgs = import args.pkgs.path {
    system = args.pkgs.hostPlatform.system;
    overlays = [ gst-overlay ];
  };
  minimalMkShell = import ./_minimal.nix { inherit pkgs; };
in
minimalMkShell {
  # TODO use something else for system?
  name = "shell-gstreamer-devenv";
  hardeningDisable = [ "fortify" ];

  LIBCLANG_PATH = "${llvmPackages.libclang}/lib";
  RUST_BACKTRACE = 1;
  GST_PLUGIN_SYSTEM_PATH = gstreamerPath;

  nativeBuildInputs = with pkgs; [
    (args.inputs.fenix.packages.${system}.latest.withComponents [
      "cargo"
      "clippy"
      "rust-src"
      "rustc"
      "rustfmt"
    ])
    args.inputs.fenix.packages.${system}.rust-analyzer
    cargo-watch
    bacon
    llvmPackages.lldb
    rnix-lsp

    /*tools */
    cmake
    pkg-config
    lldb
    python3
    /*nodejs*/
    nodejs
    yarn
    /*golang*/
    go
    go-outline
    gotools
    godef /*golint*/
    gopls

    pkg-config

    nixpkgs-review

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
    libusb1
    gpgme
    libgpgerror
    libgit2
    git # passrs
    dbus # passrs libsecret
    nettle # pass-rust (sequoia->nettle-sys)
    gst_all_1.gstreamer
    # gst_all_1
    libnice
    pango
    cairo
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav

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
