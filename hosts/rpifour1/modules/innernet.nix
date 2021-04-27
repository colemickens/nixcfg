{ config, pkgs, ... }:

{
  config = {
    services.innernet = {
      enable = true;
      networkName = "mynet";
      # ... ?
    }
  };
}
