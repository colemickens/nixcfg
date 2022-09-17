{ pkgs, lib, inputs, config, ... }:

let
  cipw = "fafc996b949b6d53800";
in
{
  config = {
    systemd.services."wlan-join" = {
      path = [
        pkgs.networkmanager
      ];
      script = ''
        nmcli dev wifi \
          connect "chimera-iot" \
          password "${cipw}" \
          ifname "wlan0"
      '';
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Restart = "on-failure";
      serviceConfig.RestartSec = 10;
    };
    networking.networkmanager.enable = true;
    networking.networkmanager.plugins = lib.mkForce [ ];
  };
}
