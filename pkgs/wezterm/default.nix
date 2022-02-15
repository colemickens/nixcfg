args_@{ lib
, fetchFromGitHub
, wezterm
# , qqc2-desktop-style, sonnet, kio
# , extra-cmake-modules
, pkg-config
, zlib
, ... }:

let
  metadata = rec {
    repo_git = "https://github.com/wez/wezterm";
    branch = "main";
    rev = "4a1c4b55662e6f6217f84137baa5ed0776753e56";
    sha256 = "sha256-tIbNFZUiGorOrmVxC9OJ5y0R2P6Ruc5xSo/D+JuToBk=";
    cargoSha256 = "sha256-UkoGBoEg8q5gjc18J/6Uh68HHbBKJuFopDtu8kOsBAQ=";
  };
  extraNativeBuildInputs = [
    # "extra-cmake-modules"
    "pkg-config"
  ];
  extraBuildInputs = [
    # "qqc2-desktop-style" "sonnet" "kio"
    "zlib"
  ];
  ignore = [ "wezterm" "fetchFromGithub" ] ++ extraBuildInputs;
  args = lib.filterAttrs (n: v: (!builtins.elem n ignore)) args_;
  newsrc = fetchFromGitHub {
    owner = "wez";
    repo = "wezterm";
    inherit (metadata) rev sha256;
    fetchSubmodules = true;
  };
in
(wezterm.override args).overrideAttrs(old: {
  pname = "wezterm";
  version = "${metadata.rev}";
  src = newsrc;

  cargoDeps = old.cargoDeps.overrideAttrs (lib.const {
    src = newsrc;
    outputHash = metadata.cargoSha256;
  });

  buildInputs = old.buildInputs ++ (map (n: args_.${n}) extraBuildInputs);
  nativeBuildInputs = old.nativeBuildInputs ++ (map (n: args_.${n}) extraNativeBuildInputs);

  meta = (old.meta or {}) // { verinfo = metadata; };
})
