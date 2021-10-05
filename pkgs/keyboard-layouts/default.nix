{ stdenv, lib, rustPlatform, fetchFromGitHub
, pkgconfig
, openssl
}:

let
  metadata = import ./metadata.nix;
in
rustPlatform.buildRustPackage rec {
  pname = "keyboard-layouts";
  version = metadata.rev;

  src = fetchFromGitHub {
    owner = "colemickens";
    repo = pname;
    rev = metadata.rev;
    sha256 = metadata.sha256;
  };

  cargoSha256 = metadata.cargoSha256;

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ openssl ];

  meta = with lib; {
    description = "Get the keycodes and modifier keys required to type an ASCII string for a number of different keyboard layouts.";
    homepage = "https://github.com/chris-ricketts/keyboard-layouts";
    license = licenses.asl20;
    maintainers = [ maintainers.colemickens ];
  };
}
