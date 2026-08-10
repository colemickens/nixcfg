{
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    ./base.nix
    inputs.determinate.nixosModules.default
  ];

  config = {  };
}
