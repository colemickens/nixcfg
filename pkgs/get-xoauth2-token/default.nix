{ stdenv
, lib
, rustPlatform
, fetchFromGitHub
, libgpgerror
, libgit2
, gpgme
, gnupg
}:

let
  verinfo = {
    repo_git = "https://github.com/colemickens/get-xoauth2-token";
    branch = "master";
    rev = "5ce47ccc3cc63300b03c0a9c0edc50ae9a88de77";
    sha256 = "sha256-j0Fd57sfAiOL10N4D7MAUdqj24XG0IEqYp2iNFwJfa8=";
    cargoSha256 = "sha256-LpAh91by82w5/9S6f0/pyE6Q5ecMjzrvJreN/5rqNdg=";
  };
in
rustPlatform.buildRustPackage rec {
  pname = "get-xoauth2-token";
  version = verinfo.rev;

  src = fetchFromGitHub {
    owner = "colemickens";
    repo = pname;
    rev = verinfo.rev;
    sha256 = verinfo.sha256;
  };

  cargoSha256 = verinfo.cargoSha256;

  passthru.verinfo = verinfo;

  meta = with lib; {
    description = "gets an xoauth2 token for use with gmail";
    homepage = "https://github.com/colemickens/get-xoauth2-token";
    license = licenses.mit;
    maintainers = [ maintainers.colemickens ];
  };
}
