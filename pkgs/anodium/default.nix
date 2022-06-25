{ stdenv, lib, fetchFromGitHub, rustPlatform
, pkg-config, makeWrapper
# , glib, cairo, pango, atk
, mesa, udev, xorg
, libinput, libseat
}:

let
  metadata = import ./metadata.nix;
in
rustPlatform.buildRustPackage rec {
  name = "anodium";
  version = metadata.rev;

  src = fetchFromGitHub {
    owner = "PolyMeilex";
    repo = "Anodium";
    rev = version;
    sha256 = metadata.sha256;
  };

  cargoSha256 = metadata.cargoSha256;

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];
  buildInputs = [
    udev mesa libinput libseat
    xorg.libXcursor xorg.libXrandr xorg.libXi
  ];
  
  # TODO: makeWrapper for EGL?

  strictDeps = true; #?

  meta = with lib; {
    description = "WIP Wayland Compositor";
    homepage = "https://github.com/PolyMeilex/Anodium";
    verinfo = metadata;
    # license = licenses.gpl3;
    maintainers = with maintainers; [ colemickens ];
  };
}
