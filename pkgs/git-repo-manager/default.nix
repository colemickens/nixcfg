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
    version = "unstable-2023-02-07";
    rev = "60a777276f7dcd841e9a11721084a4e8844cc69b";
    owner = "hakoerber";
    pname = "git-repo-manager";
    src = fetchFromGitHub {
      owner = owner;
      repo = pname;
      rev = rev;
      hash = "sha256-fShwUpD3+EqD5RhsmHD7gt4V4hALLQ81cpptyWDCgFU=";
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
