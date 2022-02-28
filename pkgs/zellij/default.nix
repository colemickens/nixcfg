args_@{ lib
, fetchFromGitHub
, zellij
, ... }:

let
  metadata = rec {
    owner = "zellij-org";
    pname = "zellij";
    repo = pname;
    repo_git = "https://github.com/${owner}/${repo}";
    version = builtins.substring 0 10 metadata.rev;
    branch = "main";
    rev = "04ce77267332a59fbf5a2b181b7f01439f099054";
    sha256 = "sha256-VXwHeoO+F6VW7QgUQALS1BXZHN3BqXmNX0AwPVtonoA=";
    cargoSha256 = "sha256-Vdzvuu8gLEmnUHbpDKglNbGWd7hH0IxjxK3phQjr1kM=";
  };
  extraNativeBuildInputs = [
  ];
  extraBuildInputs = [
  ];
  ignore = [ metadata.pname "fetchFromGithub" ] ++ extraBuildInputs;
  args = lib.filterAttrs (n: v: (!builtins.elem n ignore)) args_;
  newsrc = fetchFromGitHub {
    owner = metadata.owner;
    repo = metadata.repo;
    inherit (metadata) rev sha256;
    fetchSubmodules = true;
  };
in
(args_."${metadata.pname}".override args).overrideAttrs(old: rec {
  pname = metadata.pname;
  version = metadata.version;
  src = newsrc;

  cargoDeps = old.cargoDeps.overrideAttrs (lib.const {
    name = "${metadata.pname}-${metadata.version}-vendor.tar.gz";
    src = newsrc;
    inherit version;
    outputHash = metadata.cargoSha256;
  });

  buildInputs = old.buildInputs ++ (map (n: args_.${n}) extraBuildInputs);
  nativeBuildInputs = old.nativeBuildInputs ++ (map (n: args_.${n}) extraNativeBuildInputs);

  meta = (old.meta or {}) // { description = "${old.description or ""}"; verinfo = metadata; };
})
