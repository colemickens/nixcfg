
{ stdenv, lib, fetchFromGitHub}:

let
  metadata = rec {
    repo_git = "https://github.com/elFarto/nvidia-vaapi-driver";
    branch = "master";
    rev = "abd17d440e964fe7100fbe9f8e311c4f7cfad6ff";
    sha256 = "sha256-hzX7WLfB6SNWSQP20SsdURXwm6CJ4K4PrsyfaRaj+d0=";
    version = rev;
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
