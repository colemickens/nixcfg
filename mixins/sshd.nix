{ config, lib, pkgs, ... }:

{
  config = {
    networking.firewall.allowedTCPPorts = [ 22 ];
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        StreamLocalBindUnlink = "yes";
        # StreamLocalBindUnlink = true; # ? untested
      };
      # extraConfig = ''
      #   StreamLocalBindUnlink yes
      # '';
    };
  };
}

