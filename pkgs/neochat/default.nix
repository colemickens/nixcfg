args_@{ lib, fetchFromGitLab
, neochat
, qqc2-desktop-style, sonnet, kio
, extra-cmake-modules, pkg-config
, ... }:

let
  metadata = import ./metadata.nix;
  extraNativeBuildInputs = [
    "extra-cmake-modules" "pkg-config"
  ];
  extraBuildInputs = [
    "qqc2-desktop-style" "sonnet" "kio"
  ];
  ignore = [ "neochat" ] ++ extraBuildInputs;
  args = lib.filterAttrs (n: v: (!builtins.elem n ignore)) args_;
in
(neochat.override args).overrideAttrs(old: {
  pname = "neochat";
  version = "${metadata.rev}";
  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "network";
    repo = "neochat";
    inherit (metadata) rev sha256;
  };

  buildInputs = old.buildInputs ++ (map (n: args_.${n}) extraBuildInputs);
  nativeBuildInputs = old.nativeBuildInputs ++ (map (n: args_.${n}) extraNativeBuildInputs);
})
