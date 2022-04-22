{ lib, fetchFromGitHub, buildGoModule }:

let
  metadata = {
    repo_git = "https://github.com/aler9/rtsp-simple-server";
    branch = "main";
    rev = "9c20eedaadf230f8b566e58be849e61ea849e05e";
    sha256 = "sha256-06/YN9WUNpF3Hsf7AF6bPq1uVjwPruQG84OCmy5AV7U=";
    vendorSha256 = "sha256-fxY4RkXV5ne5i0rh9eztJRCZXO/QZZ0Uacy81GcrZ+4=";
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
