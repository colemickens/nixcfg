#!nix
{ pkgs, ... }:

let
  ## SUBS
  bootstrapScript = pkgs.writeScript "script.sh" ''BOOTSTRAP'';
  cachixFile = pkgs.writeText "config.dhall" ''CACHIXDHALL'';
  packetApiToken = "PACKETAPITOKEN";
  packetProjectId = "PACKETPROJECTID";
  userConfig = USERCONFIG;
  username = "cole";
  ## /SUBS

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
    mkdir -p /home/${username}/.config/cachix
    rm -f "/home/${username}/.config/cachix/cachix.dhall"
    cp "${cachixFile}" "/home/${username}/.config/cachix/cachix.dhall"
    tmux new-session -s "script" -d '${bootstrapScript}; read'
  '';
in
{
  imports = [ userConfig ];
  config = {
    environment.systemPackages = with pkgs; [ tmux ];
    nix.trustedUsers = [ "root" "cole" ];

    security.sudo.wheelNeedsPassword = false;

    systemd.services.buildworld = {
      description = "buildworld";
      path = with pkgs; [
        coreutils
        tmux bash nix git jq curl
        cachix openssh ripgrep gnutar gzip gawk
      ];
      serviceConfig = {
        User = username;
        Type = "oneshot";
        ExecStart = buildworldScript;
        #ExecStopPost = shutdownPacketScript;
        #Restart = "on-failure";
        RemainAfterExit = true;
      };
      wantedBy = [ "default.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
    };
  };
}
