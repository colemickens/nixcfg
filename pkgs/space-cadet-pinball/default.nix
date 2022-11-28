{ stdenv, lib, fetchFromGitHub
, cmake, pkg-config
, SDL2, SDL2_mixer
, _assets ? ""
}:

let
  verinfo = rec {
    repo_git = "https://github.com/k4zmu2a/SpaceCadetPinball";
    branch = "master";
    rev = "3be26282b39c043e684978ea052914897d6e9222";
    sha256 = "sha256-hXs6NBNsurFijGtp+M4YHN045fCwqSccApZ8Rf7/RzI=";
  };
in stdenv.mkDerivation rec {
  pname = if _assets == "" then "space-cadet-pinball" else "space-cadet-pinball-unfree";
  version = verinfo.rev;

  src = fetchFromGitHub {
    owner = "k4zmu2a";
    repo = "SpaceCadetPinball";
    rev = verinfo.rev;
    sha256 = verinfo.sha256;
  };

  nativeBuildInputs = [
    cmake pkg-config
  ];

  buildInputs = [
    SDL2 SDL2_mixer
  ];

  installPhase = ''
    true
    mkdir -p $out
    cp ../bin/SpaceCadetPinball $out/
    if [[ "${_assets}" != "" ]]; then
      cp ${_assets}/Pinball/* $out/
    fi
  '';

  passthru.verinfo = verinfo;
  meta = with lib; {
    description = "Decompilation of 3D Pinball for Windows – Space Cadet";
    homepage = "https://github.com/k4zmu2a/SpaceCadetPinball";
    license = if _assets == "" then licenses.mit else licenses.unfree;
  };
}
