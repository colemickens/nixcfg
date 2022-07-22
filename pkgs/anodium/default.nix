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
      rev = "eb4431ca4713490c6206c3c847b002100f3d65d8";
      sha256 = "sha256-v7jAI5/VaFfBl/IupAOPdJacA2sDP954W33rUO2EOGw=";
      cargoSha256 = "sha256-4b1QDqdmrihnEb4u8wWE/hH65phTXV2dXQSUEgNW/bg=";
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
