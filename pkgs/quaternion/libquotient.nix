{ mkDerivation, lib, fetchFromGitHub, cmake, qtbase, qtmultimedia }:

mkDerivation rec {
  pname = "libquotient";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "quotient-im";
    repo = "libQuotient";
    rev = version;
    sha256 = "sha256-jQ9GR/lJrhQNIt3vycN7XkUZ5mmkJ8izNQhg9Y1nQZw=";
  };

  buildInputs = [ qtbase qtmultimedia ];

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "A Qt5 library to write cross-platfrom clients for Matrix";
    homepage = "https://matrix.org/docs/projects/sdk/quotient";
    maintainers = with maintainers; [ colemickens ];
    license = licenses.lgpl21;
  };
}
