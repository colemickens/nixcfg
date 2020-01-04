{ pkgs, ... }:

{
  config = {
    # whatever else the rpi4 needs to be a real GUI machine
    systemd.services.cage-plex-mpv-shim = {

    };
  };
}
