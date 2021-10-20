{ stdenv, lib, fetchFromGitHub
, cmake
}:

let metadata = import ./metadata.nix; in
stdenv.mkDerivation rec {
  pname = "cpptoml";
  version = "${metadata.rev}";

  src = fetchFromGitHub {
    owner = "colemickens";
    repo = "cpptoml";
    rev = metadata.rev;
    sha256 = metadata.sha256;
  };

  patches = [
    ./0001-cmake-output-cpptoml.pc-for-pkg-config-discoverabili.patch
  ];

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [];

  meta = with lib; {
    description = "cpptoml is a header-only library for parsing TOML";
    homepage    = "https://github.com/skystrife/cpptoml";
    license     = licenses.mit;
    platforms   = platforms.linux;
    maintainers = with maintainers; [];
  };
}
