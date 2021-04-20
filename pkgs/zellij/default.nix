{ stdenv, rustPlatform, fetchFromGitHub }:

let
  metadata = import ./metadata.nix;
in
rustPlatform.buildRustPackage rec {
  pname = "zellij";
  version = metadata.rev;

  src = fetchFromGitHub {
    owner = "zellij-org";
    repo = pname;
    rev = metadata.rev;
    sha256 = metadata.sha256;
  };

  cargoSha256 = metadata.cargoSha256;

  meta = with stdenv.lib; {
    description = "";
    homepage = "https://github.com/zellij-org/zellij";
    license = licenses.mit;
    maintainers = [];
  };
}
