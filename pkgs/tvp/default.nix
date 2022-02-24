
{ stdenv, lib, fetchFromGitHub, pkg-config, opencv }:

let
  metadata = rec {
    repo_git = "https://github.com/TheRealOrange/terminalvideoplayer";
    branch = "main";
    rev = "c8d9542aeff030c8c6415edef106b7db97bb25e2";
    sha256 = "sha256-E1T4kGG6o+zRx72IR85uJGblP9dx15HuCdkxidhyBVQ=";
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
