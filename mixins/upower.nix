{
  pkgs,
  lib,
  config,
  modulesPath,
  inputs,
  ...
}:

{
  config = {
    services.upower = {
      enable = true;
    };
  };
}
