{ lib, fetchFromGitHub, buildGoModule }:

let
  metadata = {
    repo_git = "https://github.com/aler9/rtsp-simple-server";
    branch = "main";
    rev = "f71b7d8967973adec8b296e295f973d1b59e1151";
    sha256 = "sha256-5zTO9TLkpazUV9xklnpGiQASV1iyIu+K/2oKOaRc9N4=";
    vendorSha256 = "sha256-QX2nHIwn/UUWcm+XMFtecdiG4stXj5NKeEQuVvB+MWA=";
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
