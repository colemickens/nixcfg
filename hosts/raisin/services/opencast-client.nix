{
  config,
  pkgs,
  lib,
  ...
}:

{
  config = {
    options.opencast.publishers = {
      "rpifour2" = {
        server_uri = "ws://localhost:10443";
        type = "v4l2";
        config.device = "/dev/video4";
      };
      "rpithreebp1" = {
        server_uri = "ws://localhost:10443";
        type = "custom";
        config = {
          # TODO: this wouldn't work unless we stuff all plugins,
          # which tbf, we probably will anyway
          pipeline = ''
            gst-launch-1.0 \
              webrtcsink name="ws" signaller::address="${server_uri}" display_name="rpithreebp1" \
              v4l2src device=/dev/video0 ame="src" ! \
               videoconvert ! \
                 video/x-raw ! \
               ws.
          '';
        };
      };
      "rpizerotwo1" = {
        server_uri = "ws://localhost:10443";
        type = "v4l2";
        config.device = "/dev/video2";
      };
    };
  };
}
