{ config, pkgs, ... }:

{
  config = {
    services.jellyfin = {
      enable = true;
      package = pkgs.jellyfin;
    };
    networking.firewall.allowedTCPPorts = [ 8096 ];
  };
}

