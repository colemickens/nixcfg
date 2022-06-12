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
  verinfo = rec {
    github = {
      owner = "Rahix";
      repo = "visualizer2";
    };
    repo_git = "https://github.com/${github.owner}/${github.repo}";
    branch = "master";
    rev = "d8646e90ae15bb918ec6fb7e1dc1b5ab0547bfb5";
    sha256 = "sha256-rkxwQy29FfXbG78cAdm5en6eRzkg6Q5UOZTItlbbxwk=";
    cargoSha256 = "sha256-5q5is9joQu6KHhQugUO1jt+/78bZtt/ciBSMxhS2IYg=";
  };
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

  meta = with lib; {
    description = "OpenGL Audio Visualizers in Rust";
    license = licenses.mit;
    maintainers = [ maintainers.colemickens ];
    inherit verinfo;
  };
}
