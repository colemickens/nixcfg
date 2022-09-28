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
  owner = "PolyMeilex";
  verinfo =
    {
      repo_git = "https://github.com/${owner}/Anodium";
      branch = "master";
      rev = "7ffcc9f7b85e4044c359a9dbf0d14b8cd07dd4f4";
      sha256 = "sha256-Bzg47LmkD+idHlLH4OTt1I528mhiDx47PPx5l+gBWUk=";
      cargoSha256 = "sha256-1jNi0WlC+Ck76sCrpMRnxZr8sbtvsf8fJTLw1zu3c+0=";
    };
in
rustPlatform.buildRustPackage rec {
  name = "anodium";
  version = verinfo.rev;

  src = fetchFromGitHub {
    owner = owner;
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

  postFixup = ''
    wrapProgram "$out/bin/anodium" \
      --set "LD_LIBRARY_PATH" "${lib.makeLibraryPath buildInputs}"
  '';

  strictDeps = true; #?

  passthru.verinfo = verinfo;

  meta = with lib; {
    description = "WIP Wayland Compositor";
    homepage = "https://github.com/PolyMeilex/Anodium";
    # license = licenses.gpl3;
    maintainers = with maintainers; [ colemickens ];
  };
}
