{ config, pkgs, ... }:

{
  config = {
    services.innernet-servers = {
      enable = true;
      networkName = "mynet";
      networkCidr = "10.69.69.0/24";
      # ... ?
    };

    services.innernet-clients = {
      default = {
        server = "127.0.0.1";
        initialJoinToken = "/run/secrets/...";
      }
    };
  };
}
