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
    version = "0.7.15-unstable-2024-02-01";
    rev = "ea7299a14788556536e00bf0311bd5f650ad2600";
    owner = "hakoerber";
    pname = "git-repo-manager";
    src = fetchFromGitHub {
      owner = owner;
      repo = pname;
      rev = rev;
      hash = "sha256-pd7MZqQngyRuOLW67lx7a22pZrQjgTvNCDxzzHjxT8g=";
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
