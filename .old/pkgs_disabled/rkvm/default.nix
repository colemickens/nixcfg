{ stdenv, lib, rustPlatform, fetchFromGitHub
, pkg-config, libevdev, openssl, llvmPackages, linuxHeaders
}:

let
  metadata = {
    repo_git = "https://github.com/htrefil/rkvm";
    branch = "master";
    rev = "bf133665eb446d9f128d02e4440cc67bce50f666";
    sha256 = "sha256-naWoLo3pPETkYuW4HATkrfjGcEHSGAAXixgp1HOlIcg=";
    cargoSha256 = "sha256-md3Pu8JMKFTumgASnu2GSRlWQkqoslGwV1BWl2nQ0Zw=";
  };
in rustPlatform.buildRustPackage rec {
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
    verinfo = metadata;
    description = "Virtual KVM switch for Linux machines";
    homepage = "https://github.com/htrefil/rkvm";
    license = licenses.mit;
    maintainers = [ maintainers.colemickens ];
  };
}

