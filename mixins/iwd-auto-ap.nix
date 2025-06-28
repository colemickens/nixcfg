{ pkgs, ... }:

let
  n1 = (
    pkgs.writeText "openstick-auto-ap.ap" ''
      [Security]
      Passphrase=openstick

      [IPv4]
      Address=192.168.250.1
      Gateway=192.168.250.1
      Netmask=255.255.255.0
      DNSList=8.8.8.8
    ''
  );
  script = pkgs.writeShellScript "start" ''
    set -x
    iwctl="${pkgs.iwd}/bin/iwctl"

    sleep 10 # eh?
    if $iwctl station wlan0 show | grep State | grep -v disconnected | grep connected; then
      echo "station connected, no need for AP"
    else
      echo "station not connected, starting AP"
      $iwctl device wlan0 set-property Mode ap
      $iwctl ap wlan0 start-profile 'openstick-auto-ap'
    fi
  '';
in
{
  config = {
    networking.wireless.iwd = {
      enable = true;
      settings = {
        General.EnableNetworkConfiguration = true;
      };
    };

    systemd.services."iwd-auto-ap" = {
      path = [ pkgs.iwd ];
      script = script.outPath;
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Restart = "on-failure";
      serviceConfig.RestartSec = 10;
    };

    systemd.tmpfiles.rules = [ "C /var/lib/iwd/ap/openstick-auto-ap.ap 0600 root root - ${n1}" ];
  };
}
