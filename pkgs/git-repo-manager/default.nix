{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, runCommand
, makeRustPlatform
, # , rustPlatform
  openssl
, zlib
, zstd
, pkg-config
, python3
, xorg
, libiconv
, nghttp2
, libgit2
, testers
, fenix
,
}:

let
  toolchain = fenix.packages.${stdenv.hostPlatform.system}.minimal.toolchain;

  rustPlatform = (
    makeRustPlatform {
      cargo = toolchain;
      rustc = toolchain;
    }
  );
in
# (fenix.packages.${stdenv.hostPlatform.system}.latest.withComponents [
  # "cargo"
  # "clippy"
  # "rust-src"
  # "rustc"
  # "rustfmt"
  # ]);
rustPlatform.buildRustPackage (
  let
    version = "0.7.16-unstable-2024-04-27";
    rev = "3a433a1acdf99e4f0bd7e6726ea6a2814f82b26d";
    owner = "hakoerber";
    pname = "git-repo-manager";
    src = fetchFromGitHub {
      owner = owner;
      repo = pname;
      rev = rev;
      hash = "sha256-OFB7X8jIo2cSkOfk5t7W/WI/BIwZARRanfawHtjNz14=";
    };
  in
  {
    inherit version pname;
    inherit src;

    cargoLock = {
      lockFile = ./Cargo.lock;
    };

    nativeBuildInputs = [ pkg-config ];

    buildInputs = [
      openssl
      zstd
    ];

    # buildFeatures = additionalFeatures [ (lib.optional withDefaultFeatures "default") ];

    # meta = with lib; {
    #   description = "A modern shell written in Rust";
    #   homepage = "https://www.nushell.sh/";
    #   license = licenses.mit;
    #   maintainers = with maintainers; [ Br1ght0ne johntitor marsam ];
    #   mainProgram = "nu";
    # };
  }
)
