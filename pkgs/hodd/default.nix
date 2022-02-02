{ stdenv, lib, fetchFromGitHub}:

let
  metadata = import ./metadata.nix;
in
stdenv.mkDerivation rec {
  pname = "hodd";
  version = metadata.rev;

  src = fetchFromGitHub {
    owner = "rroemhild";
    repo = pname;
    rev = metadata.rev;
    sha256 = metadata.sha256;
  };

  skipBuild = true;

  installPhase = ''
    cp -a "${src}" "$out"
  '';

  meta = with lib; {
    description = "Homie Device Discovery";
    homepage = "https://github.com/rroemhild/hodd";
    license = licenses.mit;
    maintainers = [ maintainers.colemickens ];
    broken = true; # not finishing yet: https://github.com/bytebeamio/rumqtt/issues/338
  };
}