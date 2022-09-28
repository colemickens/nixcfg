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
      rev = "fba6f0bff5c972ad4393dd93ed72f2c27ccbd470";
      sha256 = "sha256-AJ97OLvDmDkkhsWHmdznRMj8v6Sy4reHi166ty25tco=";
      cargoSha256 = "sha256-6s7VcMFzSObh6TTArr+P16pGAEoJA55lbD71RvVPxGc=";
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
