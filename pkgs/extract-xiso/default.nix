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
      owner = "XboxDev";
      repo = "extract-xiso";
    };
    repo_git = "https://github.com/${github.owner}/${github.repo}";
    branch = "master";
    rev = "4488c39d7aa0bd0c371929a3fdeb456123aa46b3";
    sha256 = "";
    cargoSha256 = "";
  };
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
  
  passthru.verinfo = verinfo;

  meta = with lib; {
    description = "extract-xiso";
    # license = some bullshit
    maintainers = [ maintainers.colemickens ];
  };
}
