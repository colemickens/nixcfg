{ stdenv, lib, fetchFromGitHub, rustPlatform, cmake, pkgconfig
, gtk3, qt5, ncurses
, python3, openssl, libgpgerror, gpgme
}:

with rustPlatform;

let
  metadata = import ./metadata.nix;
in buildRustPackage rec {
  name = "ripasso-${version}";
  version = metadata.rev;

  src = fetchFromGitHub {
    owner = "cortex";
    repo = "ripasso";
    rev = metadata.rev;
    sha256 = metadata.sha256;
  };

  cargoSha256 = "0ivxn9cqzlg62jrsyd0nbalg19m5cmvqzfid8c0w1h6680w9grlr";

  nativeBuildInputs = [ cmake pkgconfig ];
  cargoBuildFlags = [ "--all" ];

  buildInputs = [
    gtk3 ncurses
    qt5.qtbase qt5.qtsvg qt5.qtdeclarative
    python3 openssl libgpgerror gpgme
  ];

  meta = with stdenv.lib; {
    description = "A simple password manager written in Rust";
    homepage = "https://github.com/cortex/ripasso";
    maintainers = maintainers.colemickens;
    platforms = platforms.linux;
    license = with licenses; [ gpl2 ];
  };
}
