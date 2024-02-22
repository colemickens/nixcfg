{
  pkgs,
  lib,
  inputs,
  ...
}:

let
  mapping = "cole:ffKBkSoiV7KcwUcdpjagrP9P4Gj4SFLxnZHRp3gy/jZbOD3J5xGCyidt9ruyA9ZT+DkV/lKd78Wy4RAEM8qodQ==,DfllypvIlTkhzZKEdVdRQb7iYev7K0TvpzaREkT2CFlhz4j/3vwWHzGBpQToxA2YOR1/Mwbm0cb4VxDJXs4k9g==,es256,+presence";

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
