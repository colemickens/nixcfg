
{ stdenv, lib, fetchFromGitHub}:

let
  metadata = rec {
    repo_git = "https://github.com/elFarto/nvidia-vaapi-driver";
    branch = "master";
    rev = "df18c2e2176eb5e3f6c1ae1320838fbce0e8d054";
    sha256 = "sha256-qq7IJnvz69ct5FzS57/oYnJ2X3rAWzWAxgHPfkDZ6io=";
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
