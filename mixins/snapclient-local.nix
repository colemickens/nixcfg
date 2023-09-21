{ pkgs, lib, modulesPath, inputs, config, ... }:

let
  host = "192.168.1.10";
in
{
  config = {
    systemd.user.services.snapclient-local = rec {
      # wantedBy = [ "basic.target" ];
      wantedBy = [ "graphical-session.target" ];
      requires = [
        "pipewire.socket"
        "pipewire.service"
        "pipewire-pulse.socket"
        "pipewire-pulse.service"
      ];
      after = requires;
      serviceConfig = {
        ExecStart = "${pkgs.snapcast}/bin/snapclient --logsink system --host ${host} --player pulse";
        Restart = "always";
        RestartSec = 5;
      };
    };
  };
}
