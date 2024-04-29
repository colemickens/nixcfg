{
  pkgs,
  lib,
  modulesPath,
  inputs,
  config,
  extendModules,
  ...
}:

{
  imports = [
    ./base.nix
    ./fs.nix

    # ../../profiles/interactive.nix
  ];

  config = { };
}
