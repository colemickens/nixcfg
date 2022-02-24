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
    rev = "abbf40e0148d20d7c9c933c29b6a1fd17bd8b32c";
    sha256 = "sha256-O4Kh916VZPC12l60ovFA27anjIriZ9TUuSaH5TvDDlA=";
    cargoSha256 = "sha256-mAr1ADhNnCSNdoTW/4yA3NXmVD3iGJLQoswW4v8puOo=";
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
