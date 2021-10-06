{ stdenv, lib, rustPlatform, fetchFromGitHub
, pkg-config
, openssl, llvmPackages
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

  doCheck = false; # TODO
  #nativeBuildInputs = [ llvmPackages.clang pkg-config openssl ];
  #buildInputs = [ openssl ];
  #BINDGEN_EXTRA_CLANG_ARGS = "-I${lib.getDev libevdev}/include/libevdev-1.0";
  #LIBCLANG_PATH = "${lib.getLib llvmPackages.libclang}/lib";
  
  meta = with lib; {
    description = "Get the keycodes and modifier keys required to type an ASCII string for a number of different keyboard layouts.";
    homepage = "https://github.com/chris-ricketts/keyboard-layouts";
    license = licenses.asl20;
    maintainers = [ maintainers.colemickens ];
  };
}
