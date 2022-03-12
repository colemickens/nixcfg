{ stdenv, lib, rustPlatform, fetchFromGitHub
, libgpgerror, libgit2, gpgme, gnupg }:

let
  metadata = import ./metadata.nix;
in
rustPlatform.buildRustPackage rec {
  pname = "rumqtt";
  version = metadata.rev;

  src = fetchFromGitHub {
    owner = "bytebeamio";
    repo = pname;
    rev = metadata.rev;
    sha256 = metadata.sha256;
  };

  cargoSha256 = metadata.cargoSha256;

  meta = with lib; {
    description = "Mqtt ecosystem in rust";
    homepage = "https://github.com/bytebeamio/rumqtt";
    license = licenses.asl20; # and MIT
    maintainers = [ maintainers.colemickens ];
  };
}