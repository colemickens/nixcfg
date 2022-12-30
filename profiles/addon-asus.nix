{ pkgs, lib, config, ... }:

{
  config = {
    programs = {
      rog-control-center.enable = true;
    };
    services = {
      asusd = {
        enable = true;
        enableUserService = true;
      };
      supergfxd.enable = true;
    };
  };
}
