{ stdenv, rustPlatform, fetchFromGitLab
, pkgconfig
}:

let
  metadata = import ./metadata.nix;
in
rustPlatform.buildRustPackage rec {
  pname = "conduit";
  version = metadata.rev;

  src = fetchFromGitLab {
    owner = "famedly";
    repo = pname;
    rev = metadata.rev;
    sha256 = metadata.sha256;
  };

  cargoSha256 = metadata.cargoSha256;

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [];

  meta = with stdenv.lib; {
    description = "Conduit is a simple, fast and reliable chat server powered by Matrix";
    homepage = "https://conduit.rs";
    license = licenses.asl20;
    maintainers = [ maintainers.colemickens ];
  };
}
