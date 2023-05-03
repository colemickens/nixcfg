{ pkgs, lib, modulesPath, inputs, config, ... }:

{
  imports = [
    ./inner.nix
    ./fs.nix
    ../../profiles/addon-cross.nix
    ../../profiles/gui-sway-auto.nix
  ];
}
