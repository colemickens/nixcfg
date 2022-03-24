args_@{ lib
, fetchFromGitHub
, solo2-cli
, ... }:

let
  metadata = rec {
    repo_git = "https://github.com/solokeys/solo2-cli";
    branch = "main";
    rev = "82ee2732594648409097745cecf7fb57c3b232c8";
    sha256 = "sha256-o6TrxVuVVt69mdXC+UqcrzBCvbN46sVmjNMkGmBGOYM=";
    cargoSha256 = "sha256-BxrHAkn2q1F9M6V1ekCU5b+Bhr4IyEgSmwqRrB5StNo=";
  };
  extraNativeBuildInputs = [
  ];
  extraBuildInputs = [
  ];
  ignore = [ "solo2-cli" "fetchFromGithub" ] ++ extraBuildInputs;
  args = lib.filterAttrs (n: v: (!builtins.elem n ignore)) args_;
  newsrc = fetchFromGitHub {
    owner = "solokeys";
    repo = "solo2-cli";
    inherit (metadata) rev sha256;
    fetchSubmodules = true;
  };
  version = builtins.substring 0 10 metadata.rev;
in
(solo2-cli.override args).overrideAttrs(old: rec {
  pname = "solo2-cli";
  inherit version;
  src = newsrc;

  cargoDeps = old.cargoDeps.overrideAttrs (lib.const {
    name = "${pname}-${version}-vendor.tar.gz";
    src = newsrc;
    inherit version;
    outputHash = metadata.cargoSha256;
  });

  buildInputs = old.buildInputs ++ (map (n: args_.${n}) extraBuildInputs);
  nativeBuildInputs = old.nativeBuildInputs ++ (map (n: args_.${n}) extraNativeBuildInputs);

  meta = (old.meta or {}) // { description = "${old.description or "zeterm"}"; verinfo = metadata; };
})
