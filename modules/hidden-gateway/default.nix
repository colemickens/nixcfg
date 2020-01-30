{ pkgs, ... }:

#let
  #mkService = "";
  #mkService "web.abcd.onion" ":3000"
  #mkService "web.abcd.onion" ":3000"
#in
let
  oh = "pslivaruemhjwytgi7apek6jkearbmpam54e6pvv2wlxgalve5ilefyd.onion";
  internal_port = 9901;
in
{
  config = {
    networking.firewall.allowedTCPPorts = [ internal_port ];
    services.nginx = {
      enable = true;
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
        "dash" = {
          name = "dash";
          map = [{
            port = "80";
            toPort = toString internal_port;
          }];
          version = 3;
        };
        "secretplans" = {
          name = "secretplans";
          map = [{
            port = "80";
            toPort = "9902";
          }];
          version = 3;
        };
      };
    };
  };
}

