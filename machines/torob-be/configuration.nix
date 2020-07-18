{ config, pkgs, lib, ... }:

let
  ob_pubkey = "dpkhemrbs3oiv2fww5sxs6r2uybczwijzfn2ezy2osaj7iox7kl7nhad";
  ob_pk_key = "${ob_pubkey}.key";
  ob_pk_url = "${ob_pubkey}.onion";
{
  services.tor = {
    enable = true;
    hiddenServices = {
      "ssh" = {
        name = "ssh";
        map = [{
          port = "22";
          toPort = "22";
        }];
        # extra Config = "MasterOnionAddress xyz.onion";
        # extra Config = "MasterOnionAddress xyz.onion";
        #privateKeyPath = "/home/cole/hs_ed25519_secret_key";
        version = 3;
      };
    };
  };

  # hostname, hs_ed25519_public_key, ob_config files

  services.onionbalance = {
    enable = true;
    settings = {
      services = [{
        instances = [{
          address = "pubkey.onion";
          name = "node1";
        }];
        key = "/run/secrets/privkey.key";
      }];
    };
  };

  #networking.firewall.allowedTCPPorts = [ internal_port ];
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
      "test.${oh}" = {
        listen = [ { addr = "0.0.0.0"; port = internal_port; } ];
        locations = {
          "/".proxyPass = "http://127.0.0.1:3000";
        };
      };
    };

    services.gogs = {
      enable = true;
    };
  };
}