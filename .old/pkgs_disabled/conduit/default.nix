{ stdenv, lib, rustPlatform, fetchFromGitLab
, pkgconfig
, openssl, llvmPackages
, cmake, ninja
}:

let
  metadata = {
    repo_git = "https://gitlab.com/famedly/conduit.git/";
    branch = "master";
    rev = "faa0cdb595f9d398f4a209027f1a596a4f870a39";
    sha256 = "sha256-jCBvenwXPgYms5Tbu16q/F8UNpvaw0Shao9kLEZLbHM=";
    cargoSha256 = "sha256-YvoF5DZhAMpXb9L/cPCCg8w6iMfO86YhEd1w7x7mAck=";
    revdate = "2020-08-31 06:57:21Z";
  };
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

  LIBCLANG_PATH = "${lib.getLib llvmPackages.libclang}/lib";

  cargoSha256 = metadata.cargoSha256;

  nativeBuildInputs = [ pkgconfig cmake ninja ];
  buildInputs = [ openssl ];

  meta = with lib; {
    verinfo = metadata;
    description = "Conduit is a simple, fast and reliable chat server powered by Matrix";
    homepage = "https://conduit.rs";
    license = licenses.asl20;
    maintainers = [ maintainers.colemickens ];
  };
}
