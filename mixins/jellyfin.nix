{ config, ... }:

{
  config = {
    services.jellyfin = {
      enable = true;
    };
    networking.firewall.allowedTCPPorts = [ 8096 ];
  };
}

