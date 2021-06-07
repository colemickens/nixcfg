{ stdenv, lib, fetchFromGitHub
, cmake
}:

let metadata = {
    rev="121b4b664fd7b98546bb45adc4d45ee8a3043295";
    sha256="sha256-vBIImuiUqeZXhNQ55qpS8+wxCddnHu4jIY+dsjieHHE=";
}; in
stdenv.mkDerivation rec {
  pname = "cpptoml";
  version = "${metadata.rev}";

  src = fetchFromGitHub {
    owner = "colemickens";
    repo = "cpptoml";
    rev = metadata.rev;
    sha256 = metadata.sha256;
  };

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
