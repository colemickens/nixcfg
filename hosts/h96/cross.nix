{ pkgs, lib, modulesPath, inputs, config, extendModules, ... }:

{
  imports = [
    ./inner.nix
    ./fs.nix
    ../../profiles/addon-cross.nix
  ];
}
