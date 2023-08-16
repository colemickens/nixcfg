{ pkgs, lib, modulesPath, extendModules, inputs, config, ... }:

{
  imports = [
    ./inner.nix
    ../../profiles/interactive.nix
    ../../profiles/gui-sway-auto.nix
  ];

  config = {
  };
}
