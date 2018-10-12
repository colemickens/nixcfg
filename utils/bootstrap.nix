#!nix
{ config, lib, pkgs, ... }:

let
  bootstrapDevice = "packet-kube";
  bootstrapPkgs = with pkgs; [ bash curl git nix tmux gnutar gzip sudo ];
  bootstrapScript = pkgs.writeScript "bootstrap.sh" ''
    #!/usr/bin/env bash
    set -x
    set -euo pipefail
    [[ ! -d /etc/nixcfg ]] && sudo git clone https://github.com/colemickens/nixcfg /etc/nixcfg
    cd /etc/nixcfg
    git remote update
    git reset --hard origin/master
    cd /etc/nixcfg/utils
    echo "bootstrap starting"
    ./bootstrap.sh "${bootstrapDevice}"
    echo "bootstrap complete"
    touch /var/lib/bootstrap-complete
    sleep 180
    reboot
  '';
in
{
  environment.systemPackages = bootstrapPkgs;
  systemd.services.bootstrap = {
    description = "bootstrap";
    path = bootstrapPkgs;
    unitConfig = {
      ConditionPathExists = "!/var/lib/bootstrap-complete"
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = "${bootstrapScript}";
      Restart = "on-failure";
    };
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
  };
}

