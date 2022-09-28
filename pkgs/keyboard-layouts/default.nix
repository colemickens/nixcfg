{ stdenv
, lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, openssl
, llvmPackages
}:

let
  verinfo = {
    repo_git = "https://github.com/chris-ricketts/keyboard-layouts";
    branch = "master";
    rev = "35ab89e81160aa64bde9dc0b6d97954f65dc4a2d";
    sha256 = "sha256-W+iArJX7JJm1REgFay7c7idvoRcgEr6kO10GMct7u+A=";
    cargoSha256 = "sha256-XzIhtIGTKeULBR9eJBtjYZlEFpKTXviiOufmjJ6b4No=";
  };
in
rustPlatform.buildRustPackage rec {
  pname = "keyboard-layouts";
  version = verinfo.rev;

  src = fetchFromGitHub {
    owner = "chris-ricketts";
    repo = pname;
    rev = verinfo.rev;
    sha256 = verinfo.sha256;
  };

  cargoSha256 = verinfo.cargoSha256;

  doCheck = false; # TODO
  #nativeBuildInputs = [ llvmPackages.clang pkg-config openssl ];
  #buildInputs = [ openssl ];
  #BINDGEN_EXTRA_CLANG_ARGS = "-I${lib.getDev libevdev}/include/libevdev-1.0";
  #LIBCLANG_PATH = "${lib.getLib llvmPackages.libclang}/lib";

  passthru.verinfo = verinfo;

  meta = with lib; {
    description = "Get the keycodes and modifier keys required to type an ASCII string for a number of different keyboard layouts.";
    homepage = "https://github.com/chris-ricketts/keyboard-layouts";
    license = licenses.asl20;
    maintainers = [ maintainers.colemickens ];
  };
}
