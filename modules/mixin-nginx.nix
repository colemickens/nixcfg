{ config, lib, pkgs, ... }:

{
  config = {
    services.nginx = {
      enable = true;
      virtualHosts = {
        "default" = {
          default = true;
          root = "/media/data/Media";
          extraConfig = ''
            autoindex on;
          '';
        };
      };
    };
  };
}

