{ pkgs, lib, modulesPath, inputs, config, extendModules, ... }:

{
  imports = [
    ./inner.nix
    ../../profiles/addon-cross.nix
  ];
}
