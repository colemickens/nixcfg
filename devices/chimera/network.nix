{ config, lib, pkgs, ... }:

let
in {
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  networking = {
    networkmanager.enable = false;

    defaultGateway = "192.168.1.1";
    dhcpcd.enable = false;
    nameservers = [ "192.168.1.1" ];
    firewall.extraCommands = ''iptables -t nat -A POSTROUTING -s10.100.0.0/24 -j MASQUERADE'';
    interfaces = {
      enp3s0 = {
        ipv4.addresses = [ { address = "192.168.1.16"; prefixLength = 24; } ];
      };
    };
    wireguard.interfaces = {
      wg0 = {
        ips = [ "10.100.0.1/24" ];
        listenPort = 51820;
        privateKeyFile = "/secrets/wireguard/chimera/server_private_key";

        peers = [
          { # xeep
            publicKey = "uOu3d86RHVQRbLtd912Tb/iXk+BCRsN5PZa3cOJSEDE=";
            allowedIPs = [ "10.100.0.2/32" ];
          }
        ];
      };
    };
  };
}
