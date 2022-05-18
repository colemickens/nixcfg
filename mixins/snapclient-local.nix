{ pkgs, lib, modulesPath, inputs, config, ... }:

{
  config = {
    systemd.user.services.snapclient-local = {
      wantedBy = [ "basic.target" ];
      requires = [ "pipewire.service" ];
      after = [ "pipewire.service" ];
      serviceConfig = {
        ExecStart = "${pkgs.snapcast}/bin/snapclient --host 192.168.1.10 --player pulse";
      };
    };
  };
}
