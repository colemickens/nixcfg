args_@{ lib
, fetchFromGitHub
, zellij
# , qqc2-desktop-style, sonnet, kio
# , extra-cmake-modules, pkg-config
, ... }:

let
  metadata = rec {
    repo_git = "https://github.com/zellij-org/zellij";
    branch = "main";
    rev = "10a22c479ffb4d76627eadbee2dc4b53ae4309c3";
    sha256 = "sha256-nFph0c9GEvZR1Ao7oiNH2ewlQkUBfQxJFtNHfHo6vSI=";
    cargoSha256 = "sha256-sE4ytwQpeGg396c4aksGPEnaNu1oDl+AqIiKOcLy3p4=";
  };
  extraNativeBuildInputs = [
    # "extra-cmake-modules" "pkg-config"
  ];
  extraBuildInputs = [
    # "qqc2-desktop-style" "sonnet" "kio"
  ];
  ignore = [ "zellij" "fetchFromGithub" ] ++ extraBuildInputs;
  args = lib.filterAttrs (n: v: (!builtins.elem n ignore)) args_;
  newsrc = fetchFromGitHub {
    owner = "zellij-org";
    repo = "zellij";
    inherit (metadata) rev sha256;
  };
in
(zellij.override args).overrideAttrs(old: {
  pname = "zellij";
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
