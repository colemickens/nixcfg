{ config, lib, pkgs, ... }:

{
  config = {
    networking.firewall.allowedTCPPorts = [ 22 ];
    services.openssh = {
      enable = true;
      passwordAuthentication = false;
      permitRootLogin = lib.mkForce "no";
      extraConfig = ''
        StreamLocalBindUnlink yes
      '';
    };
  };
}

