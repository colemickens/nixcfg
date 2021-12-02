{ config, pkgs, inputs, ... }:

{
  config = { 
    networking.firewall.allowedTCPPorts = [ 22000 ];
    networking.firewall.allowedUDPPorts = [ 22000 21027 ];

    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 8384 ];

    home-manager.users.cole = { pkgs, ... }: {
      services.syncthing = {
        enable = true;
      };
    };
  };
}

