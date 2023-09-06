{ lib
, fetchFromGitHub
, rustPlatform
, nixosTests
, nix-update-script

, autoPatchelfHook
, ncurses
, pkg-config

, gcc-unwrapped
, fontconfig
, libGL
, vulkan-loader
, libxkbcommon

, withX11 ? true
, libX11
, libXcursor
, libXi
, libXrandr
, libxcb

, withWayland ? true
, wayland
}:
let
  rlinkLibs = [
    (lib.getLib gcc-unwrapped)
    fontconfig
    libGL
    libxkbcommon
    vulkan-loader
  ] ++ lib.optionals withX11 [
    libX11
    libXcursor
    libXi
    libXrandr
    libxcb
  ] ++ lib.optionals withWayland [
    wayland
  ];
in
rustPlatform.buildRustPackage rec {
  pname = "rio";
  version = "unstable-2023-09-06";

  src = fetchFromGitHub {
    owner = "raphamorim";
    repo = "rio";
    rev = "66806cc363ee76345d4463349c19ea3eab6d178a";
    hash = "sha256-FkJ/ncenU/p0KSIeDSStl7OOPGbhcR10dhdBBnwq80o=";
  };

  # cargoHash = "sha256-jev4fMwCygVzvrkI1nSE5tx59nGqNKQUHCNHvkr9R90=";
  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  nativeBuildInputs = [
    autoPatchelfHook
    ncurses
    pkg-config
  ];

  runtimeDependencies = rlinkLibs;

  buildInputs = rlinkLibs;

  outputs = [ "out" "terminfo" ];

  buildNoDefaultFeatures = true;
  buildFeatures = [
    (lib.optionalString withX11 "x11")
    (lib.optionalString withWayland "wayland")
  ];

  checkFlags = [
    # Fail to run in sandbox environment.
    "--skip=screen::context::test"
  ];

  postInstall = ''
    install -D misc/rio.desktop -t $out/share/applications/
    install -D misc/logo.svg -t $out/share/icons/hicolor/scalable/apps/rio.svg

    install -dm 755 "$terminfo/share/terminfo/r/"
    tic -xe rio,rio-direct -o "$terminfo/share/terminfo" misc/rio.terminfo
    mkdir -p $out/nix-support
    echo "$terminfo" >> $out/nix-support/propagated-user-env-packages
  '';

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [ "--version-regex" "v([0-9.]+)" ];
    };

    tests.test = nixosTests.terminal-emulators.rio;
  };

  meta = {
    description = "A hardware-accelerated GPU terminal emulator powered by WebGPU";
    homepage = "https://raphamorim.io/rio";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ otavio oluceps ];
    platforms = lib.platforms.unix;
    changelog = "https://github.com/raphamorim/rio/blob/v${version}/CHANGELOG.md";
  };
}
