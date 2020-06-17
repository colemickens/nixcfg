{ stdenv, rustPlatform, fetchFromGitHub
, libgpgerror, libgit2, gpgme, gnupg }:

let
  _rev = "8ab984cb5c5c3451b1b3c4d7094541d4052739ab";
  _sha256 = "118svvgxvi6863yn9chv1cymw2xlgn4mwfryh5snfjgrcnsnn0lb";
  _cargoSha256 = "1w7w3kvs0sixb39dj94wz8azskxkkg1ff528a0xwwywkd3asq9i9";
in
rustPlatform.buildRustPackage rec {
  pname = "passrs";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "cole-h";
    repo = pname;
    rev = _rev;
    sha256 = _sha256;
  };

  cargoSha256 = _cargoSha256;

  nativeBuildInputs = [ libgpgerror gpgme gnupg ];
  buildInputs = [ gpgme libgpgerror libgit2 ];

  # Some tests require the presence of a test key.
  preCheck = ''
    export GNUPGHOME=$(mktemp -d)
    gpg --import tests/passrs@testuser.secret.asc
    echo "4B0D9BBAC5C8329C035B125CF6EF0D39C5F84192:6:" | gpg --import-ownertrust
  '';

  meta = with stdenv.lib; {
    description = "";
    homepage = "https://github.com/cole-h/passrs";
    license = licenses.mit;
    maintainers = [ maintainers.coleh ];
  };
}