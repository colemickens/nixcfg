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
  rev = "d9b364442e2246a734d600b2a4e6475dcd48319b";
  sha256 = "sha256-lmN/45TPoxSgAhisZHVZIGXLdfIGJYD/rv4fPYWmsUo=";
  cargoSha256 = "sha256-7pWCLPOT5PcqdqQVIVI5xnkCO2pGnhSEVlXe2M7QuZI=";
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
