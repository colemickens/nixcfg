
{ stdenv, lib, fetchFromGitHub}:

let
  metadata = rec {
    repo_git = "https://github.com/elFarto/nvidia-vaapi-driver";
    branch = "master";
    rev = "v${version}";
    sha256 = "sha256-2bycqKolVoaHK64XYcReteuaON9TjzrFhaG5kty28YY=";
    version = "0.0.5";
  };
in stdenv.mkDerivation rec {
  pname = "nvidia-vaapi-driver";
  version = metadata.version;

  src = fetchFromGitHub {
    owner = "elFarto";
    repo = "nvidia-vaapi-driver";
    rev = metadata.rev;
    sha256 = metadata.sha256;
  };

  skipBuild = true;

  installPhase = ''
    cp -a "${src}" "$out"
  '';

  meta = with lib; {
    verinfo = metadata;
    description = "nvidia-vaapi-driver";
    homepage = "https://github.com/elFarto/nvidia-vaapi-driver";
    license = licenses.mit;
    maintainers = [];
  };
}
