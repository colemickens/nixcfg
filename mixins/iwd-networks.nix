{
  pkgs,
  lib,
  inputs,
  config,
  ...
}:

let
  bs = {
    # this is a network meant to be used for a phone hotspot to bootstrap
    # a machine that might be connected over wifi.
    # this means the installer can insta connect to wifi and prompt for TS
    name = "bootstrap";
    text = (
      pkgs.writeText "bootstrap.psk" ''
        [Security]
        Passphrase=bootstrap2024
      ''
    );
  };
in
{
  config = {
    sops.secrets = {
      "iwd_Mickey.psk" = {
        sopsFile = ../secrets/encrypted/iwd_Mickey.psk;
        format = "binary";
      };
      "iwd_GoonNet.psk" = {
        sopsFile = ../secrets/encrypted/iwd_GoonNet.psk;
        format = "binary";
      };
    };

    systemd.tmpfiles.rules = [
      # "C /var/lib/iwd/chimera-iot.psk 0400 root root - /run/secrets/iwd_network_chimera-iot.psk"
      (
        let
          h = bs;
        in
        "C /var/lib/iwd/${bs.name}.psk 0600 root root - ${bs.text}"
      )
      (
        let
          h = "Mickey";
        in
        "C /var/lib/iwd/${h}.psk 0600 root root - ${config.sops.secrets."iwd_${h}.psk".path}"
      )
      (
        let
          h = "GoonNet";
        in
        "C /var/lib/iwd/${h}.psk 0600 root root - ${config.sops.secrets."iwd_${h}.psk".path}"
      )
    ];
  };
}
