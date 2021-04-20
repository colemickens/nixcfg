{ stdenv, rustPlatform, fetchFromGitHub
, libgpgerror, libgit2, gpgme, gnupg }:

let
  metadata = import ./metadata.nix;
in
rustPlatform.buildRustPackage rec {
  pname = "passrs";
  version = metadata.rev;

  src = fetchFromGitHub {
    owner = "cole-h";
    repo = pname;
    rev = metadata.rev;
    sha256 = metadata.sha256;
  };

  cargoSha256 = metadata.cargoSha256;

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
    maintainers = [ maintainers.cole-h ];
  };
}