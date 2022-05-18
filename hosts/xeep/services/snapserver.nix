{ config, pkgs, lib, inputs, ... }:

let
  lp = "${pkgs.librespot}/bin/librespot";
in
{
  config = {
    services.snapserver = {
      enable = true;
      codec = "flac";
      streams = {
        tcp = {
          type = "tcp";
          location = "127.0.0.1";
          query = {
            name = "snapserver";
            mode = "server";
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
