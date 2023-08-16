{ pkgs, lib, modulesPath, extendModules, inputs, config, ... }:

{
  imports = [
    ./inner.nix
    ../../profiles/addon-tiny.nix
  ];

  config = {
  };
}
