args_@{ lib
, fetchFromGitHub
, zellij
, runCommandNoCC
# , qqc2-desktop-style, sonnet, kio
# , extra-cmake-modules, pkg-config
, ... }:

let
  metadata = rec {
    repo_git = "https://github.com/zellij-org/zellij";
    branch = "main";
    rev = "10a22c479ffb4d76627eadbee2dc4b53ae4309c3";
    sha256 = "sha256-nFph0c9GEvZR1Ao7oiNH2ewlQkUBfQxJFtNHfHo6vSI=";
    cargoSha256 = "sha256-UOqaLx0U0/Bwi0H2qd9naFxjLRJB5qiMxsAooamI72g=";
  };
  extraNativeBuildInputs = [
    # "extra-cmake-modules" "pkg-config"
  ];
  extraBuildInputs = [
    # "qqc2-desktop-style" "sonnet" "kio"
  ];
  ignore = [ "zellij" "fetchFromGithub" "runCommandNoCC" ] ++ extraBuildInputs;
  args = lib.filterAttrs (n: v: (!builtins.elem n ignore)) args_;
  newsrc = fetchFromGitHub {
    owner = "zellij-org";
    repo = "zellij";
    inherit (metadata) rev sha256;
  };
  cargo_new_version = "0.0.999-${builtins.substring 0 10 metadata.rev}";
  patched_newsrc = runCommandNoCC "patch-zellij-src" {} ''
    cp -a ${newsrc} $out
    chmod +w "$out/zellij-utils/src"
    sed -i "s/env!(\"CARGO_PKG_VERSION\");/\"${cargo_new_version}\";/" "$out/zellij-utils/src/consts.rs"
  '';
in
(zellij.override args).overrideAttrs(old: {
  pname = "zellij";
  version = "${metadata.rev}";
  src = patched_newsrc;

  cargoDeps = old.cargoDeps.overrideAttrs (lib.const {
    src = patched_newsrc;
    name = "zellij-${cargo_new_version}-vendor.tar.gz";
    outputHash = metadata.cargoSha256;
  });



  buildInputs = old.buildInputs ++ (map (n: args_.${n}) extraBuildInputs);
  nativeBuildInputs = old.nativeBuildInputs ++ (map (n: args_.${n}) extraNativeBuildInputs);

  meta = (old.meta or {}) // { verinfo = metadata; };
})
