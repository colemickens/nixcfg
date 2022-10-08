{ stdenv, lib, fetchFromGitHub, pkg-config, ffmpeg_4 }:

let
  verinfo = rec {
    repo_git = "https://github.com/TheRealOrange/terminalvideoplayer";
    branch = "main";
    rev = "ca5cd21fe3508aa3a97707c18f0ec9eb92fa9bcc";
    sha256 = "sha256-riqQYAfwKrv3LpKzQObJeDP4QWVyv1YEXUChBBBVU/U=";
    version = rev;
  };
in
stdenv.mkDerivation rec {
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

  passthru.verinfo = verinfo;

  meta = with lib; {
    mainProgram = "tvp";
    description = "This is a cursed terminal video player";
    homepage = verinfo.repo_git;
    license = licenses.gpl3;
    maintainers = [ ];
  };
}
