{ pkgs, lib, modulesPath, inputs, config, ... }:

{
  config = {
    systemd.user.services.snapcast-sink = {
      wantedBy = [ "basic.target" ];
      requires = [ "pipewire.service" ];
      after = [ "pipewire.service" ];
      path = with pkgs; [ gawk pulseaudio ];

      # TODO: server probably needs to listen on PA and redirect itself to whatever sink snapserver makes
      script = ''
        set -x
        pactl unload-module module-simple-protocol-tcp || true
        sleep 1
        pactl load-module module-simple-protocol-tcp \
          name=snapsink \
          sink=192.168.1.10 \
          playback=1 \
          format=s16le \
          rate=48000
      '';
    };
  };
}
