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
        mapping_usba = "UE3cSMtyI9d4yxI7Bghg+FLiZgLaT+bjluUPuBO1HUMzzgIlIKxxGRpasmMDH+cmIaq5iobCaEu2xT1YpikU8g==,8Bgw3GYK8m9ecPaPpFkneNsREQL7RlZL7hTfEGAfm4u9Dmk22Xn3pf/+TwzpsyG1c1RBOEJkBvSvZ70P8tAgVA==,es256,+presence+pin";
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
