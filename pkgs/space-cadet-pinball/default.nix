{ stdenv, lib, fetchFromGitHub
, cmake, pkg-config
, SDL2, SDL2_mixer
, _assets ? ""
}:

let
  metadata = rec {
    repo_git = "https://github.com/k4zmu2a/SpaceCadetPinball";
    branch = "master";
    rev = "69fd91f0032d0354a404c0124e8ac94a67631318";
    sha256 = "sha256-UG0aKr44ImD426UJBe3w+uPu47HwgKv+HhiCGqHARL8=";
  };
in stdenv.mkDerivation rec {
  pname = if _assets == "" then "space-cadet-pinball" else "space-cadet-pinball-unfree";
  version = metadata.rev;

  src = fetchFromGitHub {
    owner = "k4zmu2a";
    repo = "SpaceCadetPinball";
    rev = metadata.rev;
    sha256 = metadata.sha256;
  };

  nativeBuildInputs = [
    cmake pkg-config
  ];

  buildInputs = [
    SDL2 SDL2_mixer
  ];

  installPhase = ''
    mkdir -p $out
    cp ../bin/SpaceCadetPinball $out/
    if [[ "${_assets}" != "" ]]; then
      cp ${_assets}/Pinball/* $out/
    fi
  '';

  meta = with lib; {
    verinfo = metadata;
    description = "Decompilation of 3D Pinball for Windows – Space Cadet";
    homepage = "https://github.com/k4zmu2a/SpaceCadetPinball";
    license = if _assets == "" then licenses.mit else licenses.unfree;
  };
}
