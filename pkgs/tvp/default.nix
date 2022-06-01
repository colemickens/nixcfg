
{ stdenv, lib, fetchFromGitHub, pkg-config, ffmpeg_4 }:

let
  verinfo = rec {
    repo_git = "https://github.com/TheRealOrange/terminalvideoplayer";
    branch = "main";
    rev = "8295e4948567cbe4f7854bb35adf3fd1d010a178";
    sha256 = "sha256-qDcDJXFaIqqWTpHc/MC1wQMJ4oTtEmQQ6qhDTSEjUtA=";
    version = rev;
  };
in stdenv.mkDerivation rec {
  pname = "terminalvideoplayer";
  version = verinfo.version;

  src = fetchFromGitHub {
    owner = "TheRealOrange";
    repo = "terminalvideoplayer";
    rev = verinfo.rev;
    sha256 = verinfo.sha256;
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ ffmpeg_4 ];

  buildPhase = ''
    install -d $out/bin
    g++ src/main.cpp src/video.cpp \
      -Iinc/ -std=c++17 -O3 \
      $(pkg-config --cflags --libs libavcodec libavformat libavutil libswscale) \
      -o $out/bin/tvp
  '';
  dontInstall = true;

  meta = with lib; {
    mainProgram = "tvp";
    verinfo = verinfo;
    description = "This is a cursed terminal video player";
    homepage = verinfo.repo_git;
    license = licenses.gpl3;
    maintainers = [];
  };
}
