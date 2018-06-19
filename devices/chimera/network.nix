{ config, lib, pkgs, ... }:

let
  eth0 = "enp3s0";
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

        postSetup = [
          "${pkgs.iptables}/bin/iptables -A FORWARD -i ${eth0} -j ACCEPT"
          "${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o ${eth0} -j MASQUERADE"
        ];

        postShutdown = [
          "${pkgs.iptables}/bin/iptables -D FORWARD -i ${eth0} -j ACCEPT"
          "${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -o ${eth0} -j MASQUERADE"
        ];

        peers = [
          { publicKey = "uOu3d86RHVQRbLtd912Tb/iXk+BCRsN5PZa3cOJSEDE="; allowedIPs = [ "10.100.0.2/32" ]; } # xeep
          { publicKey = "7vTuXgz7z9zhZkZdERKq1a9nt1M8/rDcFKLS57d6SXo="; allowedIPs = [ "10.100.0.3/32" ]; } # pixel2
        ];
      };
    };
  };
}
