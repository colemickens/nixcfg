args_@{ lib
, fetchFromGitHub
, bottom
# , qqc2-desktop-style, sonnet, kio
# , extra-cmake-modules, pkg-config
, ... }:

let
  metadata = rec {
    repo_git = "https://github.com/ClementTsang/bottom";
    branch = "master";
    rev = "9ef7f5d4b787b97a35c39407ce9748e11c0e2fcd";
    sha256 = "sha256-HitiraFBN65StlgQt14AxERxazHkTg2wWV1sBXMahYE=";
    cargoSha256 = "sha256-B5KqvWrhxNS2j/oFCgSWaq8gy9MowuVazwOR3LA0B4c=";
    version = rev;
  };
  extraNativeBuildInputs = [
    # "extra-cmake-modules" "pkg-config"
  ];
  extraBuildInputs = [
    # "qqc2-desktop-style" "sonnet" "kio"
  ];
  ignore = [ "bottom" "fetchFromGithub" "runCommandNoCC" ] ++ extraBuildInputs;
  args = lib.filterAttrs (n: v: (!builtins.elem n ignore)) args_;
  newsrc = bottom.src.overrideAttrs(old: {
    inherit (metadata) rev sha256;
  });
  cargo_new_version = builtins.substring 0 10 metadata.rev;
in
(bottom.override args).overrideAttrs(old: rec {
  pname = "bottom";
  version = cargo_new_version;
  src = newsrc;

  cargoDeps = old.cargoDeps.overrideAttrs (lib.const {
    src = newsrc;
    name = "${pname}-${cargo_new_version}-vendor.tar.gz";
    outputHash = metadata.cargoSha256;
  });

  buildInputs = old.buildInputs ++ (map (n: args_.${n}) extraBuildInputs);
  nativeBuildInputs = old.nativeBuildInputs ++ (map (n: args_.${n}) extraNativeBuildInputs);

  meta = (old.meta or {}) // { verinfo = metadata; };
})
