{ pkgs ? import <nixpkgs> {} }:

(pkgs.buildFHSUserEnv {
  name = "dex";
  targetPkgs = pkgs: (with pkgs; [go gnumake gcc git]);
}).env

