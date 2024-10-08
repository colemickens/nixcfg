{
  stdenv,
  lib,
  fetchFromGitHub,
  fetchpatch,
  rustPlatform,
  nixosTests,
  cmake,
  installShellFiles,
  makeWrapper,
  ncurses,
  pkg-config,
  python3,
  scdoc,
  expat,
  fontconfig,
  freetype,
  libGL,
  xorg,
  libxkbcommon,
  wayland,
  xdg-utils,
  # Darwin Frameworks
  AppKit,
  CoreGraphics,
  CoreServices,
  CoreText,
  Foundation,
  libiconv,
  OpenGL,
}:
let
  rpathLibs =
    [
      expat
      fontconfig
      freetype
    ]
    ++ lib.optionals stdenv.isLinux [
      libGL
      xorg.libX11
      xorg.libXcursor
      xorg.libXi
      xorg.libXrandr
      xorg.libXxf86vm
      xorg.libxcb
      libxkbcommon
      wayland
    ];
in
rustPlatform.buildRustPackage rec {
  pname = "alacritty";
  version = "alacritty_terminal_v0.24.0-unstable-2024-09-22";

  src = fetchFromGitHub {
    owner = "alacritty";
    repo = pname;
    rev = "4a7728bf7fac06a35f27f6c4f31e0d9214e5152b";
    hash = "sha256-ZbARlFGJsqtOF0Iv/8uY4tHPKKOx+NON5d/qa9fZQCk=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  nativeBuildInputs = [
    cmake
    installShellFiles
    makeWrapper
    ncurses
    pkg-config
    python3
    scdoc
  ];

  buildInputs =
    rpathLibs
    ++ lib.optionals stdenv.isDarwin [
      AppKit
      CoreGraphics
      CoreServices
      CoreText
      Foundation
      libiconv
      OpenGL
    ];

  outputs = [
    "out"
    "terminfo"
  ];

  postPatch = lib.optionalString (!xdg-utils.meta.broken) ''
    substituteInPlace alacritty/src/config/ui_config.rs \
      --replace xdg-open ${xdg-utils}/bin/xdg-open
  '';

  checkFlags = [ "--skip=term::test::mock_term" ]; # broken on aarch64

  postInstall =
    (
      if stdenv.isDarwin then
        ''
          mkdir $out/Applications
          cp -r extra/osx/Alacritty.app $out/Applications
          ln -s $out/bin $out/Applications/Alacritty.app/Contents/MacOS
        ''
      else
        ''
          install -D extra/linux/Alacritty.desktop -t $out/share/applications/
          install -D extra/linux/org.alacritty.Alacritty.appdata.xml -t $out/share/appdata/
          install -D extra/logo/compat/alacritty-term.svg $out/share/icons/hicolor/scalable/apps/Alacritty.svg

          # patchelf generates an ELF that binutils' "strip" doesn't like:
          #    strip: not enough room for program headers, try linking with -N
          # As a workaround, strip manually before running patchelf.
          $STRIP -S $out/bin/alacritty

          patchelf --add-rpath "${lib.makeLibraryPath rpathLibs}" $out/bin/alacritty
        ''
    )
    + ''

      installShellCompletion --zsh extra/completions/_alacritty
      installShellCompletion --bash extra/completions/alacritty.bash
      installShellCompletion --fish extra/completions/alacritty.fish

      # install -Dm 644 alacritty.yml $out/share/doc/alacritty.yml

      install -dm 755 "$terminfo/share/terminfo/a/"
      tic -xe alacritty,alacritty-direct -o "$terminfo/share/terminfo" extra/alacritty.info
      mkdir -p $out/nix-support
      echo "$terminfo" >> $out/nix-support/propagated-user-env-packages
    '';

  dontPatchELF = true;

  passthru.tests.test = nixosTests.terminal-emulators.alacritty;

  meta = with lib; {
    description = "A cross-platform, GPU-accelerated terminal emulator";
    homepage = "https://github.com/alacritty/alacritty";
    license = licenses.asl20;
    mainProgram = "alacritty";
    maintainers = with maintainers; [
      Br1ght0ne
      mic92
    ];
    platforms = platforms.unix;
    changelog = "https://github.com/alacritty/alacritty/blob/v${version}/CHANGELOG.md";
  };
}
