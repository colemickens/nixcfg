{ stdenv
, lib
, fetchFromGitHub
, rustPlatform
, pkg-config
, makeWrapper
, glib
, cairo
, pango
, atk
, gdk-pixbuf
, gtk3
, gtk-layer-shell
, mesa
, udev
, xorg
, libxkbcommon
, libinput
, seatd
, libGL
}:

let
  owner = "chrisduerr";
  verinfo =
    {
      repo_git = "https://github.com/${owner}/catacomb";
      branch = "master";
      rev = "dd6a02fd4c690242115628f800c168954009d70c";
      sha256 = "sha256-2uMrmP4+4DecACcnd8DJU3ual+F5jIJYeg0TM4her44=";
      cargoSha256 = "sha256-2ftEk4pseNZ4K5DBY5sqVjTS4Jyx2rThdyaqjC2IsGg=";
    };
in
rustPlatform.buildRustPackage rec {
  name = "catacomb";
  version = verinfo.rev;

  src = fetchFromGitHub {
    owner = owner;
    repo = "catacomb";
    inherit (verinfo) rev sha256;
  };

  cargoSha256 = verinfo.cargoSha256;

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];
  buildInputs = [
    udev
    mesa
    libinput
    seatd
    glib
    cairo
    pango
    atk
    gdk-pixbuf
    gtk3
    gtk-layer-shell
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXi
    libxkbcommon
    libGL
  ];

  # postFixup = ''
  #   wrapProgram "$out/bin/catacomb" \
  #     --set "LD_LIBRARY_PATH" "${lib.makeLibraryPath buildInputs}"
  # '';

  strictDeps = true; #?

  passthru.verinfo = verinfo;

  meta = with lib; {
    license = licenses.gpl3;
    maintainers = with maintainers; [ colemickens ];
  };
}
