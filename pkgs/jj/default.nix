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

let metadata = import ./metadata.nix; in
rustPlatform.buildRustPackage rec {
  pname = "jujube";
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

  meta = with stdenv.lib; {
    description = "Jujube (an experimental VCS)";
    homepage = "https://github.com/martinvonz/jj";
    license = licenses.asl20;
    platforms = platforms.linux;
  };
}
