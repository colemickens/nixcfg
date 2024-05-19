{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, runCommand
, rustPlatform
, openssl
, zlib
, zstd
, pkg-config
, python3
, xorg
, libiconv
, Libsystem
, AppKit
, Security
, nghttp2
, libgit2
, doCheck ? true
, withDefaultFeatures ? true
, additionalFeatures ? (p: p)
, testers
, nushell
, nix-update-script
,
}:

rustPlatform.buildRustPackage (
  let
    version = "0.93.0-unstable-2024-05-19";
    rev = "baeba19b22c08e7a4c6cf3f1ff4b37df0c54987a";
    owner = "nushell";
    pname = "nushell";
    src = fetchFromGitHub {
      owner = owner;
      repo = pname;
      rev = rev;
      sha256 = "sha256-P513Dgwn2u1lWyhI2uGgADHSVapvHnuLtXpUDANZOH0=";
    };
  in
  {
    inherit version pname;
    inherit src;

    cargoLock = {
      lockFile = ./Cargo.lock;
      outputHashes = {
        "reedline-0.32.0" = "sha256-uAx7jJ3UlRgHXVwxIT8unsB+UZBaqLLDpfZKwLqhD7k=";
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
