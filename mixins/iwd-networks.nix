{ pkgs, lib, inputs, config, ... }:

let
  n1 = (pkgs.writeText "chimera-iot.psk" ''
    [Security]
    Passphrase=fafc996b949b6d53800

  '');
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
      "C /var/lib/iwd/chimera-iot.psk 0600 root root - ${n1}"
      (let h = "Mickey"; in "C /var/lib/iwd/${h}.psk 0600 root root - ${config.sops.secrets."iwd_${h}.psk".path}")
      (let h = "GoonNet"; in "C /var/lib/iwd/${h}.psk 0600 root root - ${config.sops.secrets."iwd_${h}.psk".path}")
    ];
  };
}
