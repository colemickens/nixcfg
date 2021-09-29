{ stdenv, lib
, fetchFromGitHub
, pkgconfig, cmake, git
, alsa-lib, systemd, live555, log4cpp
}:

let
  metadata = import ./metadata.nix;
in stdenv.mkDerivation {
  pname = "v4l2rtspserver";
  version = metadata.rev;

  src = fetchFromGitHub {
    owner = "mpromonet";
    repo = "v4l2rtspserver";
    rev = metadata.rev;
    sha256 = metadata.sha256;
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    pkgconfig cmake

    # TODO: set VERSION ourselves in a saner way
    git # if we don't give it git, it doesn't set VERSION and won't compile, ugh
  ];

  # https://github.com/mpromonet/v4l2rtspserver/blob/master/Dockerfile#L7
  # ca-certificates g++ autoconf automake libtool xz-utils cmake make pkg-config git wget libasound2-dev
  buildInputs = [
    alsa-lib systemd live555
    log4cpp
  ];

  meta = with lib; {
    description = "RTSP Server for V4L2 device capture supporting HEVC/H264/JPEG/VP8/VP9";
    homepage = "https://github.com/mpromonet/v4l2rtspserver";
    license = licenses.unlicense;
    maintainers = with maintainers; [ colemickens ];
  };
}
