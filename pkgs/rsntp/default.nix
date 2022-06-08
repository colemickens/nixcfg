{ stdenv, lib, rustPlatform, fetchFromGitHub
, pkg-config
, alsa-lib, libpulseaudio
, sfml, csfml
, wayland, libglvnd
, makeWrapper
}:

let
  verinfo = rec {
    github = {
      owner = "mlichvar";
      repo = "rsntp";
    };
    repo_git = "https://github.com/${github.owner}/${github.repo}"; 
    branch = "master";
    rev = "918fc2ccf4a2e3efa40a598d9d6abdc19def6408";
    sha256 = "sha256-5SgiZhRcbCpNf9uuoutuRP+/00tTxYLDNhWMUep7tcE=";
    cargoSha256 = "sha256-hF5XsGV7SmDGjEF/nC9ufcDNvT9tjuCMv0qY/vkICUU=";
  };
in
rustPlatform.buildRustPackage rec {
  pname = "rsntp";
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
    alsa-lib libpulseaudio
    sfml csfml
    wayland libglvnd
  ];
  
  inherit (verinfo) cargoSha256;

  meta = with lib; {
    description = "High-performance NTP server written in Rust";
    license = licenses.mit;
    maintainers = [ maintainers.colemickens ];
    inherit verinfo;
  };
}
