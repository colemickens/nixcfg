{ stdenv
, lib
, fetchFromGitHub
, rustPlatform
, pkgconfig
, openssl
, dbus
, sqlite
, file
, gzip
, makeWrapper
}:

let metadata = {
  repo_git = "https://github.com/martinvonz/jj";
  branch = "main";
  rev = "03e6b8c0e6a44d12494a7467f626108ebba2fbec";
  sha256 = "sha256-mhK2fF54IjQjQpb9fzvjuLK/pzmAxWxOt6cDpjpFeT0=";
  cargoSha256 = "sha256-lp42XmY7G+4ECtAfHOrBkWZmE6HBza5y3U17u0DWt40=";
  # skip = true;
};
in rustPlatform.buildRustPackage rec {
  pname = "jujutsu";
  version = metadata.rev;

  src = fetchFromGitHub {
    owner = "martinvonz";
    repo = "jj";
    rev = metadata.rev;
    sha256 = metadata.sha256;
  };

  cargoSha256 = metadata.cargoSha256;
  nativeBuildInputs = [ pkgconfig gzip makeWrapper ];
  buildInputs = [ openssl dbus sqlite ];

  meta = with lib; {
    verinfo = metadata;
    description = "Jujutsu (an experimental VCS)";
    homepage = "https://github.com/martinvonz/jj";
    license = licenses.asl20;
    platforms = platforms.linux;
  };
}
