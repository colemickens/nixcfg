with import <nixpkgs> {};

stdenv.mkDerivation {
  name = "devenv";
  buildInputs = [
    rustc cargo gcc

    pkgconfig openssl
    libudev
  ];

  # Set Environment Variables
  RUST_BACKTRACE = 1;
}

