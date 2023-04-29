{ config, pkgs, lib, ... }:

{
  config = {
    services.zrepl = {
      enable = true;
    };
  };
}
