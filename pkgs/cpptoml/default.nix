{ stdenv, fetchFromGitHub
, cmake
}:

let metadata = {
    rev="v0.1.1";
    sha256="sha256-PcPIajifRQE0Qjx1rQX6vPRgq6lSCdZRrlNrmyZtj34=";
}; in
stdenv.mkDerivation rec {
  pname = "cpptoml";
  version = "${metadata.rev}";

#   src = fetchFromGitHub {
#     owner = "skystrife";
#     repo = "cpptoml";
#     rev = metadata.rev;
#     sha256 = metadata.sha256;
#   };
  src = /home/cole/code/cpptoml;

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [];

  meta = with stdenv.lib; {
    description = " cpptoml is a header-only library for parsing TOML";
    homepage    = "https://github.com/skystrife/cpptoml";
    license     = licenses.mit;
    platforms   = platforms.linux;
    maintainers = with maintainers; [];
  };
}
