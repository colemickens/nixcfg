{ pkgs, lib, modulesPath, inputs, config, ... }:

{
  imports = [
    ./inner.nix
    ../../profiles/core.nix
    ../../profiles/addon-tiny.nix
  ];
}
