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
    rev = "d8646e90ae15bb918ec6fb7e1dc1b5ab0547bfb5";
    sha256 = "sha256-rkxwQy29FfXbG78cAdm5en6eRzkg6Q5UOZTItlbbxwk=";
    cargoSha256 = "sha256-5q5is9joQu6KHhQugUO1jt+/78bZtt/ciBSMxhS2IYg=";
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
