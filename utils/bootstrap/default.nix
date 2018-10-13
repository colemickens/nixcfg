#!nix
{ config, lib, pkgs, ... }:

let
  sentinelPath = "/var/lib/bootstrap-complete";
  bootstrapDevice = "packet-kube";
  bootstrapPkgs = with pkgs; [ bash curl git nix tmux gnutar gzip sudo ];
  bootstrapScript = pkgs.writeScript "bootstrap.sh" ''
    #!/usr/bin/env bash
    set -x
    set -euo pipefail
    curl "https://raw.githubusercontent.com/colemickens/nixcfg/master/utils/bootstrap/bootstrap.sh" > /tmp/bootstrap.sh
    chmod +x /tmp/bootstrap.sh
    /tmp/bootstrap.sh
    touch ${sentinelPath}
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
      ConditionPathExists = "!${sentinelPath}";
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

