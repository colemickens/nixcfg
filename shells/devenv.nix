{ pkgs, inputs, ... }:

let
  # llvmPackages = pkgs.llvmPackages_13;
  llvmPackages = pkgs.llvmPackages_13;

  gstreamerPath = ""
    + ":" + "${pkgs.gst_all_1.gst-plugins-base}/lib/gstreamer-1.0"
    + ":" + "${pkgs.gst_all_1.gst-plugins-good}/lib/gstreamer-1.0"
    + ":" + "${pkgs.gst_all_1.gst-plugins-bad}/lib/gstreamer-1.0"
    + ":" + "${pkgs.gst_all_1.gst-plugins-ugly}/lib/gstreamer-1.0"
  ;

  minimalMkShell = import ./_minimal.nix { inherit pkgs; };
in
minimalMkShell {
  # TODO use something else for system?
  name = "shell-devenv";
  hardeningDisable = [ "fortify" ];

  LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";
  RUST_BACKTRACE = 1;
  GST_PLUGIN_SYSTEM_PATH = gstreamerPath;

  nativeBuildInputs = inputs.self.devShells.${pkgs.stdenv.hostPlatform.system}.devtools.nativeBuildInputs ++ (with pkgs; [
    pkg-config

    /* coreboot */
    # flashrom # use nixos module for udev rules
    gst_all_1.gstreamer
    # gst_all_1
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-plugins-rs
  ]);

  buildInputs = with pkgs; [
    llvmPackages.libclang
    llvmPackages.libclang.lib
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
    # gst_all_1
    libnice
    pango
    cairo
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav

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
