{ config, pkgs, ... }:

{
  config = {
    services.avahi = {
      enable = true;
      publish.domain = true;
      publish.enable = true;
    };
  };
}
