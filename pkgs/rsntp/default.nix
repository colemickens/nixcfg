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
    rev = "9463eb9955cc62c5b608532c9867dbd5b7688039";
    sha256 = "sha256-YmzCwG1RBTzUJE22WukcvqGRbrBPLHmWdkYOZ3MV38w=";
    cargoSha256 = "sha256-osVFbfn3qiCuN3+WzAzj9PbUHnmn+XewwTNQ50IX/7w=";
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

  passthru.verinfo = verinfo;

  meta = with lib; {
    description = "High-performance NTP server written in Rust";
    license = licenses.mit;
    maintainers = [ maintainers.colemickens ];
  };
}
