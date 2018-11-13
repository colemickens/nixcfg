with import <nixpkgs> {};

stdenv.mkDerivation {
  name = "rust-env";
  buildInputs = [
    rustc cargo

    # Example Additional Dependencies
    pkgconfig openssl
  ];

  # Set Environment Variables
  RUST_BACKTRACE = 1;
}

