{
  networking.firewall.allowedTCPPorts = [ 32400 ];
  services = {
    nginx.virtualHosts.xelpweb = {
      listen = {
        addr = "192.168.1.10";
        port = 80;
      };
      locations = {
        "/" = {
          root = "/media/data/Media/tvshows";
        };
      };
    };
    plex = {
      enable = true;
    };
  };
}

