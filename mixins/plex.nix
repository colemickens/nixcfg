{ config, pkgs, lib, ... }:

let rules =
  {
    allowedTCPPorts = [ 32400 3005 8324 32469 ];
    allowedUDPPorts = [ 1900 5353 32410 32412 32413 32414 ];
  };
in {
  config = {
    networking.firewall = rules;
    services = {
      plex = {
        enable = true;
        openFirewall = false;
      };
      jellyfin = {
        enable = true;
        openFirewall = true;
      };
    };
  };
}
