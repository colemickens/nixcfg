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
, libseat
, libGL
}:

let
  verinfo =
    {
      repo_git = "https://github.com/colemickens/Anodium";
      branch = "master";
      rev = "441d2fded4a23bbc16e524ad869e3aa779ff00a0";
      sha256 = "sha256-/hD+MSDE75+fmkdXy081i+bBBT5SQI8B32UtsYxgGrg=";
      cargoSha256 = "sha256-bArNL/b8Eeo1afYe4MJAWPZTrFgweYi0xHRQhf2iBHg=";
    };
in
rustPlatform.buildRustPackage rec {
  name = "anodium";
  version = verinfo.rev;

  src = fetchFromGitHub {
    owner = "colemickens";
    repo = "Anodium";
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
    libseat
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

  postFixup = ''
    wrapProgram "$out/bin/anodium" \
      --set "LD_LIBRARY_PATH" "${lib.makeLibraryPath buildInputs}"
  '';
  
  strictDeps = true; #?

  meta = with lib; {
    description = "WIP Wayland Compositor";
    homepage = "https://github.com/PolyMeilex/Anodium";
    verinfo = verinfo;
    # license = licenses.gpl3;
    maintainers = with maintainers; [ colemickens ];
  };
}
