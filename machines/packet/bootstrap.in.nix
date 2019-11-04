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
    echo "shutting down in 5 minutes"
    sleep $(( 60 * 5 ))
    devid="$(curl -s "https://metadata.packet.net/2009-04-04/meta-data/instance-id")"
    curl -X DELETE -H "X-Auth-Token: ${packetApiToken}" \
      "https://api.packet.net/devices/$devid"
  '';

  buildworldScript = pkgs.writeScript "buildworld" ''
    #!/usr/bin/env bash

    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p curl git jq cachix
    set -x
    set -euo pipefail
    rm -rf ~/.config/cachix
    mkdir -p ~/.config/cachix
    cp "${cachixFile}" ~/.config/cachix/cachix.dhall

    git config --global user.name "Cole Mickens"
    git config --global user.email "cole.mickens@gmail.com"

    #cachix use nixpkgs-wayland
    #cachix use colemickens

    mkdir -p ~/code/overlays

    export GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
    [[ ! -d ~/code/nixcfg ]] \
      && git clone https://github.com/colemickens/nixcfg ~/code/nixcfg
    [[ ! -d ~/code/nixpkgs ]] \
      && git clone https://github.com/colemickens/nixpkgs ~/code/nixpkgs
    [[ ! -d ~/code/overlays/nixpkgs-wayland ]] \
      && git clone https://github.com/colemickens/nixpkgs-wayland ~/code/overlays/nixpkgs-wayland

    (cd ~/code/nixpkgs;
      #git remote add nixpkgs https://github.com/nixos/nixpkgs || true;
      #git remote add nixpkgs-channels https://github.com/nixos/nixpkgs-channels || true;
      git remote update
      git reset --hard origin/cmpkgs
    )

    (cd ~/code/overlays/nixpkgs-wayland;
      git remote update
      git reset --hard origin/master
      ./update.sh
    )

    (cd ~/code/nixcfg;
      git remote update
      git reset --hard origin/master
      ./update.sh
    )
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
        # TODO: limit retries, then shutdown
      };
      wantedBy = [ "default.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
    };
USERCONFIG
  };
}
