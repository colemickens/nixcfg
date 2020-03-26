{ pkgs, ... }:

#let
  #mkService = "";
  #mkService "web.abcd.onion" ":3000"
  #mkService "web.abcd.onion" ":3000"
#in
let
  oh = "foo.onion";
  internal_port = 9901;
in
{
  config = {
    networking.firewall.allowedTCPPorts = [ internal_port ];
    services.nginx = {
      enable = false;
      #recommendedGzipSettings = true;
      #recommendedOptimisation = true;
      #recommendedProxySettings = true;
      #recommendedTlsSettings = true;
      appendHttpConfig = ''
        server_names_hash_bucket_size 128;
      '';
      virtualHosts = {
        "_" = {
          default = true;
          listen = [ { addr = "0.0.0.0"; port = internal_port; } ];
          root = "/var/empty";
        };
        "grafana.${oh}" = {
          listen = [ { addr = "0.0.0.0"; port = internal_port; } ];
          locations = {
            "/".proxyPass = "http://127.0.0.1:3000";
          };
        };
        "prometheus.${oh}" = {
          listen = [ { addr = "0.0.0.0"; port = internal_port; } ];
          locations = { "/" = { proxyPass = "http://127.0.0.1:9090"; }; };
        };
        "homeass.${oh}" = {
          listen = [ { addr = "0.0.0.0"; port = internal_port;  } ];
          locations = { "/" = { proxyPass = "http://127.0.0.1:8123"; proxyWebsockets = true; }; };
        };
      };
    };
    services.tor = {
      enable = true;
      hiddenServices = {
        "ssh" = {
          name = "ssh";
          map = [{
            port = "22";
            toPort = "22";
          }];
          privateKeyPath = "/home/cole/hs_ed25519_secret_key";
          version = 3;
        };
      };
    };
  };
}

