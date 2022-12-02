{ stdenv
, lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, alsa-lib
, libpulseaudio
, sfml
, csfml
, wayland
, libglvnd
, makeWrapper
, cmake
}:

let
  verinfo = import ./metadata.nix;
in
stdenv.mkDerivation rec {
  pname = "extract-xiso";
  version = verinfo.rev;

  src = fetchFromGitHub {
    owner = verinfo.github.owner;
    repo = verinfo.github.repo;
    rev = verinfo.rev;
    sha256 = verinfo.sha256;
  };

  nativeBuildInputs = [
    pkg-config
    # makeWrapper
    cmake
  ];
  buildInputs = [
    alsa-lib
    libpulseaudio
    sfml
    csfml
    wayland
    libglvnd
  ];
  
  passthru.verinfo = verinfo;

  meta = with lib; {
    description = "extract-xiso";
    # license = some bullshit
    maintainers = [ maintainers.colemickens ];
  };
}
