{ pkgs, lib, modulesPath, inputs, config, extendModules, ... }:

let
  hn = "h96";
  pp = "h96";
in
{
  imports = [
    ./inner.nix
    ./fs.nix
    ../../profiles/interactive.nix
  ];

  config = { };
}
