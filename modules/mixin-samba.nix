{
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

