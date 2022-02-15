{ stdenv, lib, fetchFromGitHub}:

let
  metadata = {
    repo_git = "https://github.com/rroemhild/hodd";
    branch = "master";
    rev = "42bc5b47ed89db87307d505eceb94298077cf592";
    sha256 = "sha256-4WUSnhc5uPuMF7lvEAaweWainLEVFIA8cnENrDb2CxY=";
    cargoSha256 = "sha256-LpAh91by82w5/9S6f0/pyE6Q5ecMjzrvJreN/5rqNdg=";
    skip = true;
  };
in stdenv.mkDerivation rec {
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
    verinfo = metadata;
    description = "Homie Device Discovery";
    homepage = "https://github.com/rroemhild/hodd";
    license = licenses.mit;
    maintainers = [ maintainers.colemickens ];
    broken = true; # not finishing yet: https://github.com/bytebeamio/rumqtt/issues/338
  };
}
