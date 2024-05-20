{
  config,
  lib,
  pkgs,
  modulesPath,
  inputs,
  ...
}:

{
  config = {
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "meson64-tools" ];
  };
}
