{ pkgs }:

let
  stdenvMinimal = pkgs.stdenvNoCC.override {
    cc = null;
    preHook = "";
    allowedRequisites = null;
    initialPath = nixpkgs.lib.filter
      (a: nixpkgs.lib.hasPrefix "coreutils" a.name)
      nixpkgs.stdenvNoCC.initialPath;
    extraNativeBuildInputs = [ ];
  };
in
nixpkgs.mkShell.override {
  stdenv = stdenvMinimal;
}