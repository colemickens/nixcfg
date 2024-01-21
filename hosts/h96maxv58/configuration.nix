{ pkgs, lib, modulesPath, inputs, config, extendModules, ... }:

let
  hn = "h96maxv58";
  pp = "h96maxv58";
in
{
  imports = [
    ./inner.nix
    ./fs.nix

    # ../../profiles/interactive.nix
  ];

  config = { };
}
