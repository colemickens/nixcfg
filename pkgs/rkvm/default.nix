{ stdenv, lib, rustPlatform, fetchFromGitHub
, pkg-config, libevdev, openssl, llvmPackages, linuxHeaders
}:

let metadata = import ./metadata.nix; in
rustPlatform.buildRustPackage rec {
  pname = "rkvm-unstable";
  version = metadata.rev;

  src = fetchFromGitHub {
    owner = "htrefil";
    repo = "rkvm";
    rev = metadata.rev;
    sha256 = metadata.sha256;
  };

  cargoSha256 = metadata.cargoSha256;

  nativeBuildInputs = [ llvmPackages.clang pkg-config openssl ];
  buildInputs = [ libevdev openssl linuxHeaders ];

  BINDGEN_EXTRA_CLANG_ARGS = "-I${lib.getDev libevdev}/include/libevdev-1.0";
  LIBCLANG_PATH = "${lib.getLib llvmPackages.libclang}/lib";

  # The libevdev bindings preserve comments from libev, some of which
  # contain indentation which Cargo tries to interpret as doc tests.
  doCheck = false;

  postInstall = ''
    mv $out/bin/server $out/bin/rkvm-server
    mv $out/bin/client $out/bin/rkvm-client
    mv $out/bin/certificate-gen $out/bin/rkvm-certificate-gen
  '';

  meta = with lib; {
    description = "Virtual KVM switch for Linux machines";
    homepage = "https://github.com/htrefil/rkvm";
    license = licenses.mit;
    maintainers = [ maintainers.colemickens ];
  };
}

