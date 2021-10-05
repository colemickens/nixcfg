{ stdenv, lib
, fetchFromGitHub, fetchpatch
, pkgconfig, cmake
, alsa-lib, live555, log4cpp, openssl
# , systemd # NO do not give it systemd so it can't try to do dumb things
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

  patches = [ ./0001-cmake-find-openssl-and-live555-via-pkg-config.patch ];

  cmakeFlags = [ "-DVERSION=${metadata.rev}" ];

  nativeBuildInputs = [ pkgconfig cmake ];

  buildInputs = [ alsa-lib live555 log4cpp openssl ];

  meta = with lib; {
    description = "RTSP Server for V4L2 device capture supporting HEVC/H264/JPEG/VP8/VP9";
    homepage = "https://github.com/mpromonet/v4l2rtspserver";
    license = licenses.unlicense;
    maintainers = with maintainers; [ colemickens ];
    broken = true;
  };
}
