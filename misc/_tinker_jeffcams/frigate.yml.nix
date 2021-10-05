let
  cameras = {
    "back" = "rtsp://HA:HA123456@localhost:10121/cam/realmonitor?channel=1&subtype=1";
    "back2" = "rtsp://HA:HA123456@localhost:10122/cam/realmonitor?channel=1&subtype=1";
  };

  config = {
    mqtt = {
      host = "homeassistant.localdomain";
    };
    detectors = {
      coral = {
        type = "edgetpu";
        device = "usb";
      };
    };
    cameras = {
      back = {
        detect = {
          width = 704;
          height = 480;
          fps = 5;
        };
        ffmpeg = {
          hwaccel_args = [ "-c:v" "h264_v4l2m2m" ];
          inputs = {
            # when loaded in vlc, this stream is 704x480 (buffer is 704x482), 4:2:0 YUV, H.264 - MPEG-4 AVC (part 10) (h264)
            path =  "rtsp://HA:HA123456@localhost:10121/cam/realmonitor?channel=1&subtype=1";
            roles = [ "detect" "record" ];
          };
        };
      };
    };
    record = {
      enabled = true;
      retain_days = 0;
      events = {
        retain = {
          default = 10;
        };
      };
    };
  }
in
  pkgs.writeYAML "frigate.yml" config
