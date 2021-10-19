args_@{ lib
, fetchFromGitHub
, wezterm
, ... }:

let
  metadata = import ./metadata.nix;
  extraNativeBuildInputs = [
    # "extra-cmake-modules" "pkg-config"
  ];
  extraBuildInputs = [
    # "qqc2-desktop-style" "sonnet" "kio"
  ];
  ignore = [ "wezterm" "fetchFromGithub" ] ++ extraBuildInputs;
  args = lib.filterAttrs (n: v: (!builtins.elem n ignore)) args_;
  newsrc = fetchFromGitHub {
    owner = "wez";
    repo = "wezterm";
    inherit (metadata) rev sha256;
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
})
