{ ... }:

{
  config = {
    services.nginx = {
      enable = true;
      virtualHosts = {
        "unifi.chimera.cluster.lol" = {
          enableACME = true;
          forceSSL = true;
          locations."/".proxyPass = "http://192.168.1.10:8080";
        };
        "transmission.chimera.cluster.lol" = {
          enableACME = true;
          forceSSL = true;
          root = "/var/www/nginx";
          locations."/".proxyPass = "http://192.168.1.10:9091";
        };
      };
    };
  };
}
