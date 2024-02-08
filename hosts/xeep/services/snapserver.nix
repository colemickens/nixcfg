{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  lp = "${pkgs.librespot}/bin/librespot";
  tcp_listen_port = 4953;
in
{
  config = {
    networking.firewall.allowedTCPPorts = [ tcp_listen_port ];
    services.snapserver = {
      enable = true;
      codec = "flac";
      streams = {
        tcp = {
          type = "tcp";
          location = "0.0.0.0";
          query = {
            name = "snapserver";
            mode = "server";
            port = "${builtins.toString tcp_listen_port}";
          };
        };
        librespot = {
          type = "librespot";
          location = "${pkgs.librespot}/bin/librespot";
          query = {
            name = "librespot";
            username = "cole.mickens";
            password = "FuckSpotifySucks";
            devicename = "librespot";
            bitrate = "320";
          };
        };
      };
    };
  };
}
