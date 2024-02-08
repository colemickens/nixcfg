{
  pkgs,
  lib,
  modulesPath,
  inputs,
  config,
  ...
}:

{
  imports = [
    ./inner.nix
    ../../profiles/addon-tiny.nix
    # ../../profiles/interactive.nix
  ];
}
