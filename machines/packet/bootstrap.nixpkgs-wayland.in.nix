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

    mkdir -p /home/cole/.config/cachix
    rm -f "/home/cole/.config/cachix/cachix.dhall"
    cp "${cachixFile}" "/home/cole/.config/cachix/cachix.dhall"

    rm -rf /tmp/nixpkgs-wayland
    git clone https://github.com/colemickens/nixpkgs-wayland /tmp/nixpkgs-wayland
    cd /tmp/nixpkgs-wayland
    ./update-revs.sh
    ./update-pkgs-wayland.sh
    ./update-pkgs-chromium.sh
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
