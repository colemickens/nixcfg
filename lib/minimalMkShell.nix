{ pkgs }:

let
  stdenvMinimal = pkgs.stdenvNoCC.override {
    cc = null;
    preHook = "";
    allowedRequisites = null;
    initialPath = pkgs.lib.filter
      (a: pkgs.lib.hasPrefix "coreutils" a.name)
      pkgs.stdenvNoCC.initialPath;
    extraNativeBuildInputs = [ ];
  };
in pkgs.mkShell.override {
  stdenv = stdenvMinimal;
}