#!nix
{ pkgs, ... }:

let
  cachixFile = pkgs.copyPathToStore "/home/cole/.config/cachix/cachix.dhall";

  shutdownScript = pkgs.writeScript "shutdownPacket" ''
    #!/usr/bin/env bash
    set -x
    rid="$(curl 'http://169.254.169.254/metadata/instance/compute/resourceId?api-version=2019-06-04&format=text' -H "Metadata: true")"
    token="$(curl 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fmanagement.azure.com%2F' \
      -H Metadata:true -s | jq -r .access_token)"
    curl -H "Authorization: Bearer $token" https://management.azure.com$rid?api-version=2019-03-01
  '';

  buildworldScript = pkgs.writeScript "buildworld" ''
    #! /usr/bin/env bash
    set -x

    git config --global user.name "Cole Mickens"
    git config --global user.email "cole.mickens@gmail.com"

    cachix use nixpkgs-wayland
    cachix use colemickens

    mkdir -p ~/code
    export GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

    mkdir -p /home/cole/code/overlays

    [[ ! -d ~/code/nixpkgs ]] && git clone https://github.com/colemickens/nixpkgs ~/code/nixpkgs
    (cd ~/code/nixpkgs; git remote update; git reset --hard origin/cmpkgs)
    [[ ! -d ~/code/nixcfg ]] && git clone https://github.com/colemickens/nixcfg ~/code/nixcfg
    (cd ~/code/nixcfg; git remote update; git reset --hard origin/master)

    ff=("nixpkgs-wayland" "nixpkgs-graphics" "nixpkgs-chromium")
    for f in $ff; do
      [[ ! -d ~/code/overlays/$f ]] && git clone https://github.com/colemickens/$f ~/code/overlays/$f
      (cd ~/code/overlays/$f; git remote update; git reset --hard origin/master)
    done

    (cd ~/code/overlays/nixpkgs-chromium; ./update;)
    (cd ~/code/overlays/nixpkgs-graphics; ./update;)
    (cd ~/code/overlays/nixpkgs-wayland;  ./update;)
    (cd ~/code/overlays/nixcfg;           ./update;)
  '';
in
{
  config = {
    nix.trustedUsers = [ "root" "cole" ];
    systemd.services.buildworld = {
      description = "buildworld";
      path = with pkgs; [ bash nix git jq curl cachix openssh ripgrep gnutar gzip gawk mercurial nix-prefetch ];
      serviceConfig = {
        User = "cole";
        Type = "simple";
        ExecStart = "${buildworldScript}";
        ExecStopPost = "${shutdownScript}";
        Restart = "on-failure";
      };
      wantedBy = [ "default.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
    };
  };
}
