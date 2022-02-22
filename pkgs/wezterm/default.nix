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
    rev = "9438e49726f949b310e5efe733060f5d9ad2f4fc";
    sha256 = "sha256-eL+PUeWGHvZ68QupMlDIOHUrslbKS4dSbzVHWCf2qY0=";
    cargoSha256 = "sha256-1fN1yLBEeJPLwEoFTlwvqtEzfGD5ijpYqe8nY6NitZA=";
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

  meta = (old.meta or {}) // { description = "${old.description or "zeterm"}"; verinfo = metadata; };
})
