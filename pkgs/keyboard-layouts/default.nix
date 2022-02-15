{ stdenv, lib, rustPlatform, fetchFromGitHub
, pkg-config
, openssl, llvmPackages
}:

let
  metadata = {
    repo_git = "https://github.com/colemickens/keyboard-layouts";
    branch = "master";
    rev = "9527ae9597df38f737b3b254bf3fdeed60bdd02d";
    sha256 = "sha256-W+iArJX7JJm1REgFay7c7idvoRcgEr6kO10GMct7u+A=";
    cargoSha256 = "sha256-53g00oa66HzOf0nwALbusi3/W6Xmn7Mlshbvrp7p90k=";
  };
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
    verinfo = metadata;
    description = "Get the keycodes and modifier keys required to type an ASCII string for a number of different keyboard layouts.";
    homepage = "https://github.com/chris-ricketts/keyboard-layouts";
    license = licenses.asl20;
    maintainers = [ maintainers.colemickens ];
  };
}
