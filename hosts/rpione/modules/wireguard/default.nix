{ pkgs, config, ... }:
let
  eth = "eth0";
  wg = "wg1";
in
{
  config = {
    networking.wireguard.interfaces."${wg}" = {
      ips = [ "172.27.66.1/24" ];
      listenPort = 51820;
      privateKeyFile = config.sops.secrets."wg-server.key".path;
      peers = [
        {
          allowedIPs = [ "172.27.66.10/32" ];
          publicKey = builtins.readFile ./client-10-cole-phone.pub;
        }
        {
          allowedIPs = [ "172.27.66.11/32" ];
          publicKey = builtins.readFile ./client-11-cole-laptop.pub;
        }
        {
          allowedIPs = [ "172.27.66.20/32" ];
          publicKey = builtins.readFile ./client-20-bud-phone.pub;
        }
      ];
    };
  };
}
