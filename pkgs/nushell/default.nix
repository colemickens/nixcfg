{
  stdenv,
  lib,
  fetchFromGitHub,
  fetchpatch,
  runCommand,
  rustPlatform,
  openssl,
  zlib,
  zstd,
  pkg-config,
  python3,
  xorg,
  libiconv,
  Libsystem,
  AppKit,
  Security,
  nghttp2,
  libgit2,
  doCheck ? true,
  withDefaultFeatures ? true,
  additionalFeatures ? (p: p),
  testers,
  nushell,
  nix-update-script,
}:

rustPlatform.buildRustPackage (
  let
    version = "0.97.1-unstable-2024-09-11";
    rev = "0c139c7411774385f120bcef8d11a38246d6e232";
    owner = "nushell";
    pname = "nushell";
    src = fetchFromGitHub {
      owner = owner;
      repo = pname;
      rev = rev;
      sha256 = "sha256-H7xB8Lk19KMFb096H5+86rJJ8Uq1Oqfr5pSYN1HEzCQ=";
    };
  in
  {
    inherit version pname;
    inherit src;

    cargoLock = {
      lockFile = ./Cargo.lock;
      outputHashes = {
        "reedline-0.34.0" = "sha256-dsEvfs8sFA1bIZttP0yi5DYJ8yvBmJodsP/XwU+osu0=";
      };
    };

    nativeBuildInputs =
      [ pkg-config ]
      ++ lib.optionals (withDefaultFeatures && stdenv.isLinux) [ python3 ]
      ++ lib.optionals stdenv.isDarwin [ rustPlatform.bindgenHook ];

    buildInputs =
      [
        openssl
        zstd
      ]
      ++ lib.optionals stdenv.isDarwin [
        zlib
        libiconv
        Libsystem
        Security
      ]
      ++ lib.optionals (withDefaultFeatures && stdenv.isLinux) [ xorg.libX11 ]
      ++ lib.optionals (withDefaultFeatures && stdenv.isDarwin) [
        AppKit
        nghttp2
        libgit2
      ];

    buildFeatures = additionalFeatures [ (lib.optional withDefaultFeatures "default") ];

    # TODO investigate why tests are broken on darwin
    # failures show that tests try to write to paths
    # outside of TMPDIR
    doCheck = doCheck && !stdenv.isDarwin;

    checkPhase = ''
      runHook preCheck
      echo "Running cargo test"
      HOME=$TMPDIR cargo test
      runHook postCheck
      true
    '';

    meta = with lib; {
      description = "A modern shell written in Rust";
      homepage = "https://www.nushell.sh/";
      license = licenses.mit;
      mainProgram = "nu";
    };

    passthru = {
      shellPath = "/bin/nu";
      tests.version = testers.testVersion { package = nushell; };
      updateScript = nix-update-script { };
    };
  }
)
