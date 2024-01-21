{ pkgs, lib, modulesPath, extendModules, inputs, config, ... }:

{
  imports = [
    ./configuration.nix
    ../../profiles/addon-tiny.nix
  ];

  config = { };
}
