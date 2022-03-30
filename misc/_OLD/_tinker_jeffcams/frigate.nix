{ pkgs ? (import ../../default.nix).internals.pkgs_.nixpkgs."${builtins.currentSystem}" }:

let
  camera_names = builtins.attrNames (import ../../hosts/jeffhyper/cameras.nix);

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
    record = {
      enabled = true;
      retain_days = 0;
      events = {
        retain = {
          default = 10;
        };
      };
    };
    cameras = (pkgs.lib.genAttrs camera_names (cam_name:
      # n(ame) => 
      {
        detect = {
          width = 704;
          height = 480;
          fps = 5;
        };
        motion = {
          # block the camera's timestamp
          mask = "0,423,0,480,227,480,221,426";
        };
        ffmpeg = {
          hwaccel_args = [ "-c:v" "h264_v4l2m2m" ];
          inputs = [{
            # when loaded in vlc, this stream is 704x480 (buffer is 704x482), 4:2:0 YUV, H.264 - MPEG-4 AVC (part 10) (h264)
            path =  "rtsp://jeffhyper.ts.r10e.tech:8554/${cam_name}";
            roles = [ "detect" "record" ];
          }];
        };
      }
    ));
  };
in
  pkgs.writeText "frigate.yml" (pkgs.lib.generators.toYAML {} config)
