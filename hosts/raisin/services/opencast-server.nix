{
  config,
  pkgs,
  lib,
  ...
}:

{
  config = {
    options.opencast.server-ws = {
      enable = true;
      listen_uri = "ws://localhost:10443";
      # debug = true;
    };
    options.opencast.server-http = {
      enable = true;
      listen_uri = "http://localhost:10080";
      # debug = true;
    };
    networking.firewall.allowedTCPPorts = [
      10080 # http
      10443 # websocket
    ];
    networking.firewall.allowedUDPPorts = [
      # anything for webrtc, etc?
      # should we open external firewall for connectivity?
    ];
  };
}
