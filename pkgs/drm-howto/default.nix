{ stdenv
, fetchFromGitHub
, libdrm
, pkgconfig
}:

stdenv.mkDerivation {
  pname = "drm-sample";
  version = "2020-08-17";

  src = fetchFromGitHub {
    owner = "dvdhrm";
    repo = "docs";
    rev = "fc5c63ff723fb9aa76faf72d6ca29a6aecddd219";
    sha256 = "1ai8gzf5jzvyid16dww3j8zmh8i8aanhnbkswdlw2draf99s4bhm";
  };

  sourceRoot = "source/drm-howto";

  postPatch = ''
    sed -i -e 's/gcc/$(CC)/' Makefile
    export PKG_CONFIG_PATH="${libdrm.dev}/lib/pkgconfig"
  '';

  nativeBuildInputs = [
    pkgconfig
  ];

  buildInputs = [
    libdrm
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp * $out/bin
  '';
}