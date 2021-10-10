{ config, pkgs, lib, ... }:

let
  configFile = pkgs.writeText "rtsp-simple-server.yml" ''
    paths:
      cam1:
        source: rtsp://HA:HA123456@localhost:10121/cam/realmonitor?channel=1&subtype=1
      cam2:
        source: rtsp://HA:HA123456@localhost:10122/cam/realmonitor?channel=1&subtype=1
      cam3:
        source: rtsp://HA:HA123456@localhost:10123/cam/realmonitor?channel=1&subtype=1
      cam4:
        source: rtsp://HA:HA123456@localhost:10124/cam/realmonitor?channel=1&subtype=1
      cam5:
        source: rtsp://HA:HA123456@localhost:10125/cam/realmonitor?channel=1&subtype=1
      cam6:
        source: rtsp://HA:HA123456@localhost:10126/cam/realmonitor?channel=1&subtype=1
  '';
in {
  config = {
    systemd.services.rtsp-simple-server = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        RestartSec = 10;
        Restart = "on-failure";
      };
      script = ''
        ${pkgs.rtsp-simple-server}/bin/rtsp-simple-server "${configFile}"
      '';
    };

    systemd.services.ssh-phone-home = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        RestartSec = 10;
        Restart = "on-failure";
      };
      script = ''
        ${pkgs.openssh}/bin/ssh \
          -NTC -o ServerAliveInterval=30 \
          -o ExitOnForwardFailure=yes \
          -L0.0.0.0:10121:192.168.10.121:554 \
          -L0.0.0.0:10122:192.168.10.122:554 \
          -L0.0.0.0:10123:192.168.10.123:554 \
          -L0.0.0.0:10124:192.168.10.124:554 \
          -L0.0.0.0:10125:192.168.10.125:554 \
          -L0.0.0.0:10126:192.168.10.126:554 \
          -l cole \
          -i hydra_queue_runner_id_rsa \
          192.168.1.9
      '';
    };

  };
}
