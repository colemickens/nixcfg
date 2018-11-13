{ config, lib, pkgs, ... }:

# TODO: it'd be great if this weren't necessary...
let
  eth0 = "enp3s0";
  wgDir = "/etc/nixos/secrets/wireguard";
in {
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  networking = {
    firewall.extraCommands = ''iptables -t nat -A POSTROUTING -s10.100.0.0/24 -j MASQUERADE'';
    wireguard.interfaces = {
      wg0 = {
        ips = [ "10.100.0.1/24" ];
        listenPort = 51820;
        privateKeyFile = "${wgDir}/chimera/server_private";

        postSetup = [
          "${pkgs.iptables}/bin/iptables -A FORWARD -i ${eth0} -j ACCEPT"
          "${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o ${eth0} -j MASQUERADE"
        ];

        postShutdown = [
          "${pkgs.iptables}/bin/iptables -D FORWARD -i ${eth0} -j ACCEPT"
          "${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -o ${eth0} -j MASQUERADE"
        ];

        peers = [
          { # xeep
            publicKey = (lib.readFile "${wgDir}/xeep-nov2018/public");
            allowedIPs = [ "10.100.0.2/32" ];
          }
          { # pixel3
            publicKey = (lib.readFile "${wgDir}/pixel3-nov2018/public");
            allowedIPs = [ "10.100.0.3/32" ];
          }
        ];
      };
    };
  };
}
