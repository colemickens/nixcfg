{ stdenv
, rustPlatform
, lib
, fetchFromGitHub
, ncurses
, perl
, pkg-config
, python3
, fontconfig
, openssl
, libglvnd
, libX11
, libxcb
, libxkbcommon
, xcbutil
, xcbutilimage
, xcbutilkeysyms
, xcbutilwm
, wayland
, zlib
, CoreGraphics
, Cocoa
, Foundation
, libiconv
}:

let
  metadata = import ./metadata.nix;
  newsrc = fetchFromGitHub {
    owner = "wez";
    repo = "wezterm";
    fetchSubmodules = true;
    inherit (metadata) rev sha256;
  };
in rustPlatform.buildRustPackage rec {
  pname = "wezterm";
  version = metadata.rev;

  outputs = [ "out" "terminfo" ];

  src = newsrc;

  postPatch = ''
    echo ${version} > .tag

    # tests are failing with: Unable to exchange encryption keys
    rm -r wezterm-ssh/tests
  '';

  cargoSha256 = metadata.cargoSha256;

  nativeBuildInputs = [
    pkg-config
    python3
    ncurses # tic for terminfo
  ] ++ lib.optional stdenv.isDarwin perl;

  buildInputs = [
    fontconfig
    zlib
  ] ++ lib.optionals stdenv.isLinux [
    libglvnd
    libX11
    libxcb
    libxkbcommon
    openssl
    wayland
    xcbutil
    xcbutilimage
    xcbutilkeysyms
    xcbutilwm # contains xcb-ewmh among others
  ] ++ lib.optionals stdenv.isDarwin [
    Cocoa
    CoreGraphics
    Foundation
    libiconv
  ];

  postInstall = ''
    # terminfo
    mkdir -p $terminfo/share/terminfo/w $out/nix-support
    tic -x -o $terminfo/share/terminfo termwiz/data/wezterm.terminfo
    echo "$terminfo" >> $out/nix-support/propagated-user-env-packages

    # desktop icon
    install -Dm644 assets/icon/terminal.png $out/share/icons/hicolor/128x128/apps/org.wezfurlong.wezterm.png
    install -Dm644 assets/wezterm.desktop $out/share/applications/org.wezfurlong.wezterm.desktop
    install -Dm644 assets/wezterm.appdata.xml $out/share/metainfo/org.wezfurlong.wezterm.appdata.xml

    # helper scripts
    install -Dm644 assets/shell-integration/wezterm.sh -t $out/etc/profile.d
  '';

  preFixup = lib.optionalString stdenv.isLinux ''
    patchelf --add-needed "${libglvnd}/lib/libEGL.so.1" $out/bin/wezterm-gui
  '' + lib.optionalString stdenv.isDarwin ''
    mkdir -p "$out/Applications"
    OUT_APP="$out/Applications/WezTerm.app"
    cp -r assets/macos/WezTerm.app "$OUT_APP"
    rm $OUT_APP/*.dylib
    cp -r assets/shell-integration/* "$OUT_APP"
    ln -s $out/bin/{wezterm,wezterm-mux-server,wezterm-gui,strip-ansi-escapes} "$OUT_APP"
  '';

  meta = with lib; {
    description = "A GPU-accelerated cross-platform terminal emulator and multiplexer written by @wez and implemented in Rust";
    homepage = "https://wezfurlong.org/wezterm";
    license = licenses.mit;
    maintainers = with maintainers; [ SuperSandro2000 ];
    platforms = platforms.unix;
    # Fails on missing UserNotifications framework while linking
    broken = stdenv.isDarwin;
  };
}
