{ pkgs, lib, modulesPath, inputs, config, ... }:

let
  host = "192.168.1.10";
in {
  config = {
    systemd.user.services.snapclient-local = {
      wantedBy = [ "basic.target" ];
      requires = [ "pipewire.service" ];
      after = [ "pipewire.service" ];
      serviceConfig = {
        ExecStart = "${pkgs.snapcast}/bin/snapclient --logsink system --host ${host} --player pulse";
        Restart = "always";
        RestartSec = 5;
      };
    };
  };
}
