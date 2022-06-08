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
    rev = "e216ce948fe4f5849fd650d4a326cc971f12f545";
    sha256 = "sha256-Vpnfmn/Pe2AZEb4PEcKK/gG/fIAUlV7UzRu/U7dZ0lY=";
    cargoSha256 = "sha256-WHORAbVk6odWxpkRdyFe2D8rh7bv/GeV8IgZOZK0Pjs=";
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
