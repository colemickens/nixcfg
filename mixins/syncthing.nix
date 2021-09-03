{ config, pkgs, inputs, ... }:

{
  config = { 
    networking.firewall.allowedTCPPorts = [ 22000 ];
    networking.firewall.allowedUDPPorts = [ 22000 21027 ];
    
    home-manager.users.cole = { pkgs, ... }: {
      services.syncthing = {
        enable = true;
      };
    };
  };
}

