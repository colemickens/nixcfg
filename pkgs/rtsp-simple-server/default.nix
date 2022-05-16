{ lib, fetchFromGitHub, buildGoModule }:

let
  metadata = {
    repo_git = "https://github.com/aler9/rtsp-simple-server";
    branch = "main";
    rev = "2fba878755f4c417be3d3272eeb3fa43b9a46b1a";
    sha256 = "sha256-BhU7QVotwuiY9bO5s0PBrccGD22KSrIVrPHXkwNadZY=";
    vendorSha256 = "sha256-jb8UyVG3INqdA6R2EMPHsw+mVuGhU6jSEUEpOrBfH/s=";
  };
in buildGoModule rec {
  pname = "rtsp-simple-server";
  version = metadata.rev;

  src = fetchFromGitHub {
    owner = "aler9";
    repo = "rtsp-simple-server";
    rev = metadata.rev;
    sha256 = metadata.sha256;
  };

  vendorSha256 = metadata.vendorSha256;

  doCheck = false; # TODO: they expect ffmpeg/docker when running tests, not ok

  meta = with lib; {
    verinfo = metadata;
    description = "ready-to-use RTSP / RTMP / HLS server and proxy that allows to read, publish and proxy video and audio streams";
    homepage = "https://github.com/aler9/rtsp-simple-server";
    license = licenses.mit;
    maintainers = with maintainers; [ colemickens ];
  };
}
