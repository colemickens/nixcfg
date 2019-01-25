{
  networking.firewall = {
    allowPing = true;
    allowedTCPPorts = [ 445 139 ];
    allowedUDPPorts = [ 137 138 ];
  };
  services = {
    samba = {
      enable = true;
      extraConfig = ''
        workgroup = WORKGROUP
        server string = chimera
        #netbios name = chimera
        #max protocol = smb2
        #hosts allow = 192.168.1  localhost
        #hosts deny = 0.0.0.0/0
        guest account = nobody
        map to guest = bad user
      '';
      shares = {
        steam = {
          path = "/media/data/STEAM";
          browseable = "yes";
          public = "yes";
          "guest ok" = "yes";
          "read only" = "no";
        };
        backups = {
          path = "/media/data/BACKUPS";
          browseable = "yes";
          public = "yes";
          "guest ok" = "yes";
          "read only" = "yes";
        };
        roms = {
          path = "/media/data/Roms";
          browseable = "yes";
          public = "yes";
          "guest ok" = "yes";
          "read only" = "yes";
        };
        media = {
          path = "/media/data/Media";
          browseable = "yes";
          public = "yes";
          "guest ok" = "yes";
          "read only" = "yes";
        };
      };
    };
  };
}

