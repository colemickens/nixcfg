{ lib, fetchFromGitHub, buildGoModule }:

let
  metadata = {
    repo_git = "https://github.com/aler9/rtsp-simple-server";
    branch = "main";
    rev = "2601ca566171aea81e6b7f73788d0de80b85a48e";
    sha256 = "sha256-jUQ8+ur955phmp48Gt4HGWppId5q+/caf/dj9KH0glI=";
    vendorSha256 = "sha256-wAKnPtNIYJ8oxlcDt7+BjtYDo1qs8wB5xF4L6xMb1EA=";
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
