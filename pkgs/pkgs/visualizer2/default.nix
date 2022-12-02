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
}:

let
  verinfo = import ./metadata.nix;
  visbins = [
    "spectral"
    "noambition"
    "noa-35c3"
  ];
in
rustPlatform.buildRustPackage rec {
  pname = "visualizer2";
  version = verinfo.rev;

  src = fetchFromGitHub {
    owner = verinfo.github.owner;
    repo = verinfo.github.repo;
    rev = verinfo.rev;
    sha256 = verinfo.sha256;
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];
  buildInputs = [
    alsa-lib
    libpulseaudio
    sfml
    csfml
    wayland
    libglvnd
  ];
  postFixup = (map
    (f: ''
      wrapProgram "$out/bin/${f}" \
        --suffix LD_LIBRARY_PATH : "${lib.strings.makeLibraryPath [ wayland libglvnd ]}"
    '')
    visbins);

  inherit (verinfo) cargoSha256;
  
  passthru.verinfo = verinfo;

  meta = with lib; {
    description = "OpenGL Audio Visualizers in Rust";
    license = licenses.mit;
    maintainers = [ maintainers.colemickens ];
  };
}
