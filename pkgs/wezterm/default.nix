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
    rev = "5ffd50acc609bea0b31440cf4e992a82a3809392";
    sha256 = "sha256-8IhpAwUCImeNVaA94k7vjkYn8sEzmDU9RsOiF4SgFyw=";
    cargoSha256 = "sha256-gKcElX60ie4/KE9jw6Ub3h5RSmYmWxGObeqAzB5B5M4=";
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
