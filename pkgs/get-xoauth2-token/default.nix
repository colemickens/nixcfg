{ stdenv, rustPlatform, fetchFromGitHub
, libgpgerror, libgit2, gpgme, gnupg }:

let
  metadata = import ./metadata.nix;
in
rustPlatform.buildRustPackage rec {
  pname = "get-xoauth2-token";
  version = metadata.rev;

  src = fetchFromGitHub {
    owner = "colemickens";
    repo = pname;
    rev = metadata.rev;
    sha256 = metadata.sha256;
  };

  cargoSha256 = metadata.cargoSha256;

  meta = with stdenv.lib; {
    description = "gets an xoauth2 token for use with gmail";
    homepage = "https://github.com/colemickens/get-xoauth2-token";
    license = licenses.mit;
    maintainers = [ maintainers.colemickens ];
  };
}