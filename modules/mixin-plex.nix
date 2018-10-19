{ config, lib, pkgs, ... }:

let
in {
  imports = [
    ../../users/cole
    ../common
  ];

  networking.firewall.enable = false;

  services = {
    plex = {
      enable = true;
    };
    unifi = {
      unifiPackage = pkgs.unifiStable;
      enable = true;
    };
    transmission = {
      enable = true;
      settings = {
        rpc-whitelist = "127.0.0.1,192.168.*.*";
        umask = 2;
      };
    };
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

