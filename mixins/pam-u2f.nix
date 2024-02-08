{
  pkgs,
  lib,
  inputs,
  ...
}:

let
  mapping = "cole:ffKBkSoiV7KcwUcdpjagrP9P4Gj4SFLxnZHRp3gy/jZbOD3J5xGCyidt9ruyA9ZT+DkV/lKd78Wy4RAEM8qodQ==,DfllypvIlTkhzZKEdVdRQb7iYev7K0TvpzaREkT2CFlhz4j/3vwWHzGBpQToxA2YOR1/Mwbm0cb4VxDJXs4k9g==,es256,+presence";

  # TODO: imagine how to make this be smarter, multi-user, multi-waylands?
  # or just simply not WAYLAND_DISPLAY=1?
  # userSwayLock = pkgs.writeShellScript "ykswaylock.sh" ''
  #   export WAYLAND_DISPLAY=wayland-1
  #   export XDG_RUNTIME_DIR=/run/user/1000
  #   date '+%s'
  #   ${pkgs.swaylock}/bin/swaylock --debug --daemonize
  # '';
  # ykDisconnect = pkgs.writeShellScript "yk-disconnect.sh" ''
  #   echo "$1 - ykdisconnect"
  #   env |& sed  "s/^/[$1] /" >> /tmp/ykdisconnect.env
  #   echo "[$1]---------------" >>/tmp/ykdisconnect.env
  #   /run/current-system/sw/bin/sudo -u cole ${userSwayLock} $1 \
  #     |& sed  "s/^/[$1] /" >>/tmp/ykdisconnect.log & 2>&1
  #   echo "done $1" >>/tmp/ykdisconnect.log
  # '';

  ykDisconnect = pkgs.writeShellScript "yk-disconnect.sh" ''
    ${pkgs.procps}/bin/pkill -USR1 swayidle
  '';
in
{
  config = {
    security.pam = {
      u2f = {
        enable = true;
      };
    };

    # REVISIT:
    # - currently udev triggers this twice
    # - (AFAICT serialized, not parallelized)
    # - so in attempt to fix, use `--daemonize` in the disco script
    # - however, this ... maybe triggers a race in sway?
    # --- we end up getting a log that shows BOTH attempts to start swaylock fail, supposedly taking the lock
    # --- even though the lock screen does render for a good 1000-ish-ms.
    # --- log: https://gist.github.com/colemickens/ee0da4f9ebcabc3049c69027aecdafa6
    services.udev.extraRules = ''
      ACTION=="remove", SUBSYSTEM=="usb", ENV{PRODUCT}=="1050/406/543", RUN+="${ykDisconnect} '%E{SEQNUM}'"
    '';

    home-manager.users.cole =
      { pkgs, ... }:
      {
        xdg.configFile."Yubico/u2f_keys".text = mapping;
      };
  };
}
