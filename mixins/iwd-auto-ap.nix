{ pkgs, lib, inputs, config, ... }:

let
  n1 = (pkgs.writeText "openstick-auto-ap.ap" ''
    [Security]
    Passphrase=openstick
    
    [IPv4]
    Address=192.168.250.1
    Gateway=192.168.250.1
    Netmask=255.255.255.0
    DNSList=8.8.8.8
  '');
in
{
  config = {
    networking.wireless.iwd.enable = true;

    systemd.services."iwd-auto-ap" = {
      path = [
        pkgs.iwd
      ];
      script = ''
        iwctl device wlan0 set-Property Mode ap
        iwctl ap wlan0 start-profile 'openstick-auto-ap'
      '';
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Restart = "on-failure";
      serviceConfig.RestartSec = 10;
    };

    systemd.tmpfiles.rules = [
      "C /var/lib/iwd/ap/openstick-auto-ap.ap 0600 root root - ${n1}"
    ];
  };
}
