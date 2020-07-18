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
}