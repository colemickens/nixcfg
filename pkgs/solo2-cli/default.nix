args_@{ lib
, fetchFromGitHub
, solo2-cli
, ...
}:

let
  verinfo = rec {
    repo_git = "https://github.com/solokeys/solo2-cli";
    branch = "main";
    rev = "83b4183fe64ff7054d4b166badd0131b9265be01";
    sha256 = "sha256-TpbVIR3I1airCc54Kh8DtO9hMRtNyOy3afsnalzkKSk=";
    cargoSha256 = "sha256-pBiMEpDhGBY5KBW0Cnz5IxiUKVfkt3SeObwg+Ub75TA=";
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
    inherit (verinfo) rev sha256;
    fetchSubmodules = true;
  };
  version = builtins.substring 0 10 verinfo.rev;
in
(solo2-cli.override args).overrideAttrs (old: rec {
  pname = "solo2-cli";
  inherit version;
  src = newsrc;

  cargoDeps = old.cargoDeps.overrideAttrs (lib.const {
    name = "${pname}-${version}-vendor.tar.gz";
    src = newsrc;
    inherit version;
    outputHash = verinfo.cargoSha256;
  });

  buildInputs = old.buildInputs ++ (map (n: args_.${n}) extraBuildInputs);
  nativeBuildInputs = old.nativeBuildInputs ++ (map (n: args_.${n}) extraNativeBuildInputs);

  passthru.verinfo = verinfo;

  meta = (old.meta or { }) // { description = "${old.description or "zeterm"}"; };
})
