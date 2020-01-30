{ pkgs, config, ... }:

let
  eth = "eth0";
  wgdev = "wg1";
  wg_port = 51820;
  internal_range = "192.168.2.0/24";
in
{
  config = {
    networking.nat = {
      enable = true;
      internalInterfaces = [ wgdev ];
      internalIPs = [ internal_range ];
      externalInterface = eth;
    };
    networking.firewall = {
      enable = true;
      allowedUDPPorts = [ wg_port ];
    };
    networking.wireguard.interfaces."${wgdev}" = {
      ips = [ internal_range ];
      listenPort = wg_port;
      privateKeyFile = "${../../machines/raspberry/wg-server.key}";
      peers = [
        { allowedIPs = ["192.168.2.2/32"]; # cole-phone
          publicKey = "TVmP+Ov/RKECq98pCpoTAgJF9BKo/QrUUN+25dEnjR4="; }
        { allowedIPs = ["192.168.2.3/32"]; # buddie-phone
          publicKey = "UrVPH3QQhRNCsLfM21gv08PydwrIV6eGuStKG8mn/CI="; }
      ];
    };
  };
}

