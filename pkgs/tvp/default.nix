
{ stdenv, lib, fetchFromGitHub, pkg-config, opencv }:

let
  metadata = rec {
    repo_git = "https://github.com/TheRealOrange/terminalvideoplayer";
    branch = "main";
    rev = "8295e4948567cbe4f7854bb35adf3fd1d010a178";
    sha256 = "sha256-qDcDJXFaIqqWTpHc/MC1wQMJ4oTtEmQQ6qhDTSEjUtA=";
    version = rev;
  };
in stdenv.mkDerivation rec {
  pname = "terminalvideoplayer";
  version = metadata.version;

  src = fetchFromGitHub {
    owner = "TheRealOrange";
    repo = "terminalvideoplayer";
    rev = metadata.rev;
    sha256 = metadata.sha256;
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ opencv ];

  buildPhase = ''
    install -d $out/bin
    g++ src/main.cpp -std=c++17 -O3 \
      $(pkg-config --cflags --libs opencv4) \
      -o $out/bin/tvp
  '';
  dontInstall = true;

  meta = with lib; {
    mainProgram = "tvp";
    verinfo = metadata;
    description = "This is a cursed terminal video player";
    homepage = metadata.repo_git;
    license = licenses.gpl3;
    maintainers = [];
  };
}
