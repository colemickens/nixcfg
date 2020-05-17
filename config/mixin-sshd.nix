{ ... }:

{
  config = {
    networking.firewall.allowedTCPPorts = [ 22 ];
    services.openssh = {
      enable = true;
      passwordAuthentication = false;
      permitRootLogin = "no";
      extraConfig = ''
        StreamLocalBindUnlink yes
      '';
    };
  };
}

