{
  config,
  pkgs,
  lib,
  ...
}:

let
  configFile = pkgs.writeText "rstp-config.yml" (
    pkgs.lib.generators.toYAML { } {
      paths = {
        cam1 = {
          runOnInit = "${pkgs.ffmpeg}/bin/ffmpeg -f v4l2 -i /dev/video4 -pix_fmt yuv420p -preset ultrafast -b:v 600k -f rtsp rtsp://localhost:$RTSP_PORT/$RTSP_PATH";
          runOnInitRestart = true;
          # runOnDemand = "${pkgs.ffmpeg}/bin/ffmpeg -f v4l2 -i /dev/video4 -pix_fmt yuv420p -preset ultrafast -b:v 600k -f rtsp rtsp://localhost:$RTSP_PORT/$RTSP_PATH";
          # runOnDemandRestart = true;
        };
        cam2 = {
          runOnDemand = "${pkgs.ffmpeg}/bin/ffmpeg -f v4l2 -i /dev/video6 -pix_fmt yuv420p -preset ultrafast -b:v 600k -f rtsp rtsp://localhost:$RTSP_PORT/$RTSP_PATH";
          runOnDemandRestart = true;
        };
      };
    }
  );
in
{
  config = {
    networking.firewall.allowedTCPPorts = [
      8554 # rtsp
      1935 # rtmp
    ];
    networking.firewall.allowedUDPPorts = [
      8000 # rtp
      8001 # rtcp
    ];

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
  };
}
