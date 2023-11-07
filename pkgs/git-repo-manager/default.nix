{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, runCommand
, makeRustPlatform
  # , rustPlatform
, openssl
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
}:

let
  toolchain = fenix.packages.${stdenv.hostPlatform.system}.minimal.toolchain;

  rustPlatform = (makeRustPlatform {
    cargo = toolchain;
    rustc = toolchain;
  });
  # (fenix.packages.${stdenv.hostPlatform.system}.latest.withComponents [
  # "cargo"
  # "clippy"
  # "rust-src"
  # "rustc"
  # "rustfmt"
  # ]);
in
rustPlatform.buildRustPackage (
  let
    version = "unstable-2023-11-06";
    rev = "b9051d5afb389be605b421053da6bdd6aaf347a1";
    owner = "hakoerber";
    pname = "git-repo-manager";
    src = fetchFromGitHub {
      owner = owner;
      repo = pname;
      rev = rev;
      hash = "sha256-NSr8wWBKwT8AOO/NSHhSnYeje2hkAyjtDwooa2RqTfE=";
    };
  in
  {
    inherit version pname;
    inherit src;

    cargoLock = {
      lockFile = ./Cargo.lock;
    };

    nativeBuildInputs = [ pkg-config ];

    buildInputs = [ openssl zstd ];

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
