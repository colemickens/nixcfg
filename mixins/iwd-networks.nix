{ pkgs, lib, inputs, config, ... }:

let
  n1 = (pkgs.writeText "chimera-iot.psk" ''
    [Security]
    Passphrase=fafc996b949b6d53800

  '');
in
{
  config = {
    networking.wireless.iwd.enable = true;

    systemd.tmpfiles.rules = [
      # "C /var/lib/iwd/chimera-iot.psk 0400 root root - /run/secrets/iwd_network_chimera-iot.psk"
      "C /var/lib/iwd/chimera-iot.psk 0600 root root - ${n1}"
    ];
  };
}
