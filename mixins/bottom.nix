{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  config = {
    home-manager.users.cole =
      { pkgs, ... }:
      {
        programs.bottom = {
          enable = true;
          # settings = {};
        };
      };
  };
}
