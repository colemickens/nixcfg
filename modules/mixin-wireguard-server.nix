{ config, lib, pkgs, ... }:

# TODO: it'd be great if this weren't necessary...
let
  eth0 = "enp3s0";
in {
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  networking = {
    firewall.extraCommands = ''iptables -t nat -A POSTROUTING -s10.100.0.0/24 -j MASQUERADE'';
    wireguard.interfaces = {
      wg0 = {
        ips = [ "10.100.0.1/24" ];
        listenPort = 51820;
        privateKeyFile = "/etc/nixos/secrets/wireguard/chimera/server_private_key";

        postSetup = [
          "${pkgs.iptables}/bin/iptables -A FORWARD -i ${eth0} -j ACCEPT"
          "${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o ${eth0} -j MASQUERADE"
        ];

        postShutdown = [
          "${pkgs.iptables}/bin/iptables -D FORWARD -i ${eth0} -j ACCEPT"
          "${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -o ${eth0} -j MASQUERADE"
        ];

        peers = [
          { publicKey = "RVJ3jkBXh3ef+sshatGqAZmaO1NVNe2a+wEwMSZjRSI="; allowedIPs = [ "10.100.0.2/32" ]; } # xeep
        ];
      };
    };
  };
}
