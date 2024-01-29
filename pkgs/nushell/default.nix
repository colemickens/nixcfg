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
}:

rustPlatform.buildRustPackage (
  let
    version = "unstable-2024-01-29";
    rev = "eea3f79c3c1b5a818a797806fd18fd6b27b03998";
    owner = "nushell";
    pname = "nushell";
    src = fetchFromGitHub {
      owner = owner;
      repo = pname;
      rev = rev;
      sha256 = "sha256-kvDpW/dFviwv9X2zCrjRnO4qj1KHf+je5SiifFyLqjg=";
    };
  in
  {
    inherit version pname;
    inherit src;

    cargoLock = {
      lockFile = ./Cargo.lock;
      outputHashes = {
        "reedline-0.28.0" = "sha256-Aud5eDKc3pfG/LyZKKUBCllAZTiY0C8mn+PWvW0+77w=";
      };
    };

    nativeBuildInputs = [ pkg-config ]
      ++ lib.optionals (withDefaultFeatures && stdenv.isLinux) [ python3 ]
      ++ lib.optionals stdenv.isDarwin [ rustPlatform.bindgenHook ];

    buildInputs = [ openssl zstd ]
      ++ lib.optionals stdenv.isDarwin [ zlib libiconv Libsystem Security ]
      ++ lib.optionals (withDefaultFeatures && stdenv.isLinux) [ xorg.libX11 ]
      ++ lib.optionals (withDefaultFeatures && stdenv.isDarwin) [ AppKit nghttp2 libgit2 ];

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
      maintainers = with maintainers; [ Br1ght0ne johntitor marsam ];
      mainProgram = "nu";
    };

    passthru = {
      shellPath = "/bin/nu";
      tests.version = testers.testVersion {
        package = nushell;
      };
      updateScript = nix-update-script { };
    };
  }
)
