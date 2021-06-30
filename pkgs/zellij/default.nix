args_@{ lib
#, fetchFromGitLab
, zellij
# , qqc2-desktop-style, sonnet, kio
# , extra-cmake-modules, pkg-config
, ... }:

let
  metadata = import ./metadata.nix;
  extraNativeBuildInputs = [
    # "extra-cmake-modules" "pkg-config"
  ];
  extraBuildInputs = [
    # "qqc2-desktop-style" "sonnet" "kio"
  ];
  ignore = [ "zellij" ] ++ extraBuildInputs;
  args = lib.filterAttrs (n: v: (!builtins.elem n ignore)) args_;
in
(zellij.override args).overrideAttrs(old: {
  pname = "zellij";
  version = "${metadata.rev}";
  # src = fetchFromGitLab {
  #   domain = "invent.kde.org";
  #   owner = "network";
  #   repo = "zellij";
  #   inherit (metadata) rev sha256;
  # };
  src = /home/cole/code/zellij;

  buildInputs = old.buildInputs ++ (map (n: args_.${n}) extraBuildInputs);
  nativeBuildInputs = old.nativeBuildInputs ++ (map (n: args_.${n}) extraNativeBuildInputs);
})
