{ stdenv, rustPlatform, fetchFromGitHub
, pkg-config, libevdev, openssl, llvmPackages_latest }:

let
  metadata = import ./metadata.nix;
in
rustPlatform.buildRustPackage rec {
  pname = "rkvm";
  version = metadata.rev;

  src = fetchFromGitHub {
    owner = "htrefil";
    repo = pname;
    rev = metadata.rev;
    sha256 = metadata.sha256;
  };

  cargoSha256 = metadata.cargoSha256;

  nativeBuildInputs = [ pkg-config openssl llvmPackages_latest.libclang ];
  LIBCLANG_PATH = "${llvmPackages_latest.libclang}/lib";
  buildInputs = [ libevdev openssl ];

  meta = with stdenv.lib; {
    description = "Virtual KVM switch for Linux machines";
    homepage = "https://github.com/htrefil/rkvm";
    license = licenses.mit;
    maintainers = [ maintainers.colemickens ];
  };
}
