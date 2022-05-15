{ stdenv, lib, fetchFromGitHub
, cmake, pkg-config
, SDL2, SDL2_mixer
, _assets ? ""
}:

let
  metadata = rec {
    repo_git = "https://github.com/k4zmu2a/SpaceCadetPinball";
    branch = "master";
    rev = "fdf1f6c9f18dce51ee8894d37314c76f1aafe95d";
    sha256 = "sha256-FnPErmWxn3l2SP6QDROgN+ivevpUOioEhHpRmP8Jt2w=";
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
