{ config, pkgs, lib, ... }:

let
  configFile = pkgs.writeText "rstp-config.yml" (pkgs.lib.generators.toYAML { } {
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
  });
in
{
  config = {
    networking.firewall.allowedTCPPorts = [
      80 # nginx
      9443 # webrtcsink-webrtc-ws
    ];
    # webrtcsink services:
    # server
    webrtcsink = {
      server = {
        enable = true;
        ws_port = 9443;
      };
      publishers = {
        "cam_rpifour2" = {
          display_name = "rpifour2";
          type = "v4l2";
          # video+audio ?
          options = {
            device_name = "/dev/video2";
          };
        };
      };
    };
    services.nginx = {
      enable = true;
      virtualHosts."homie-cast.cleo.cat" = {
        locations."/" = {
          root = "/srv/homie-cast";
          extraConfig = ''
            autoindex on;
            disable_symlinks off;
          '';
        };
      };
    };
  };
}
