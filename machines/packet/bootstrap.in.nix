#!nix
{ pkgs, ... }:

let
cachixFile = pkgs.writeText "config.dhall" ''
CACHIXDHALL
'';

  packetApiToken = "PACKETAPITOKEN";
  packetProjectId= "PACKETPROJECTID";

  shutdownPacketScript = pkgs.writeScript "shutdownPacket" ''
    #!/usr/bin/env bash
    set -x
    devid="$(curl -s "https://metadata.packet.net/2009-04-04/meta-data/instance-id")"
    echo curl -X DELETE -H "X-Auth-Token: ${packetApiToken}" \
      "https://api.packet.net/devices/$devid"
  '';

  buildworldScript = pkgs.writeScript "buildworld" ''
    #!/usr/bin/env bash
    set -x
    rm -f /tmp/buildworld.sh
    wget "https://raw.githubusercontent.com/colemickens/nixcfg/master/machines/packet/buildworld.sh" \
      -O /tmp/buildworld.sh
    chmod +x /tmp/buildworld.sh
    exec /tmp/buildworld.sh
  '';
in
{
  config = {
    nix.trustedUsers = [ "root" "cole" ];
    systemd.services.buildworld = {
      description = "buildworld";
      path = with pkgs; [ bash nix git jq curl cachix openssh ripgrep gnutar gzip gawk ];
      serviceConfig = {
        User = "cole";
        Type = "simple";
        ExecStart = "${buildworldScript}";
        ExecStopPost = "${shutdownPacketScript}";
        Restart = "on-failure";
      };
      wantedBy = [ "default.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
    };
USERCONFIG
  };
}
