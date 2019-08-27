#!nix
{ pkgs, ... }:

let
cachixFile = pkgs.writeScript "config.dhall" ''
CACHIXDHALL
'';

  packetApiToken = "PACKETAPITOKEN";
  packetProjectId= "PACKETPROJECTID";

  shutdownPacketScript = pkgs.writeScript "shutdownPacket" ''
    #!/usr/bin/env bash

    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p curl
    set -x
    devid="$(curl -s "https://metadata.packet.net/2009-04-04/meta-data/instance-id")"
    echo WOULD_HAVE curl -X DELETE -H "X-Auth-Token: ${packetApiToken}" \
      "https://api.packet.net/devices/$devid"
  '';

  buildworldScript = pkgs.writeScript "buildworld" ''
    #!/usr/bin/env bash

    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p curl git jq cachix
    set -x
    set -euo pipefail
    mkdir -p ~/.config/cachix

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
    systemd.services.buildworld = {
      description = "buildworld";
      path = with pkgs; [ bash nix git jq curl cachix openssh ];
      serviceConfig = {
        User = "cole";
        Type = "forking";
        ExecStart = "${buildworldScript}";
        ExecStopPost = "${shutdownPacketScript}";
        Restart = "on-failure";
        # TODO: limit retries, then shutdown
      };
      wantedBy = [ "default.target" ];
    };
USERCONFIG
  };
}
