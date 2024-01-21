{ config, pkgs, lib, ... }:

let
  configFile = pkgs.writeText "rstptoweb.config.json" (pkgs.lib.generators.toJSON { } {
    server = {
      debug = true;
      http_demo = true;
      http_dir = "${pkgs.rtsptoweb}/share/web";
      http_debug = true;
      http_login = "demo";
      http_password = "demo";
      http_port = ":8083";
      ice_servers = [ "stun:stun.l.google.com:19302" ];
      rtsp_port = ":5541";
    };
    channel_defaults = {
      on_demand = true;
    };
    streams = {
      cam1 = {
        name = "cam1";
        channels = {
          "0" = {
            name = "cam1-chan0";
            url = "rtsp://192.168.19.37/cam1";
            on_demand = false;
            debug = true;
            audio = true;
            status = 0;
          };
        };
      };
    };
  });
in
{
  config = {
    systemd.services.rtsptoweb = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        RestartSec = 10;
        Restart = "on-failure";
      };
      script = ''
        ${pkgs.rtsptoweb}/bin/RTSPtoWeb -config "${configFile}"
      '';
    };
  };
}
