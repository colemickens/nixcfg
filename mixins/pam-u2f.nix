{
  pkgs,
  lib,
  inputs,
  ...
}:

let
  ykDisconnect = pkgs.writeShellScript "yk-disconnect.sh" ''
    ${pkgs.systemd}/bin/loginctl lock-sessions
  '';
in
{
  config = {
    # auto-lock device on removal of ANY yubikey-looking USB device
    services.udev.extraRules = ''
      ACTION=="remove", SUBSYSTEM=="usb", ENV{PRODUCT}=="1050/406/543", RUN+="${ykDisconnect} '%E{SEQNUM}'"
    '';

    # enable pam_u2f integration
    security.pam.u2f.enable = true;

    # enable the u2f keys for my user
    # (NOTE: "Yubico" is just a questionable default, apparently, see "authFile" option)
    home-manager.users.cole =
      let
        mapping_usba = "ffKBkSoiV7KcwUcdpjagrP9P4Gj4SFLxnZHRp3gy/jZbOD3J5xGCyidt9ruyA9ZT+DkV/lKd78Wy4RAEM8qodQ==,DfllypvIlTkhzZKEdVdRQb7iYev7K0TvpzaREkT2CFlhz4j/3vwWHzGBpQToxA2YOR1/Mwbm0cb4VxDJXs4k9g==,es256,+presence";
        mapping_usbc = "GxHJs340o/neC4/4jQKPwUM9TodnS7IEZ/onrzzY8UTLagT7dpi2lzZ8vANmXI9O4JeaK68XlhfBuFJbSPmVjg==,6/v6kyT7Oj8RfcBQYPuncn7PPM6/CHYSYSmeTfWJkdZoal0Bk3hqkGeA3QwK9PYqSrZgKMIDR4pmQRlKDl/SQg==,es256,+presence";
      in
      ({ pkgs, ... }:
      {
        xdg.configFile."Yubico/u2f_keys".text = ''
          cole:${mapping_usba}:${mapping_usbc}
        '';
      });
  };
}
