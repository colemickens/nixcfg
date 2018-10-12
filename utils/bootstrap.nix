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
    cd /etc/nixcfg/utils
    ./bootstrap.sh "${bootstrapDevice}"
    touch /var/lib/bootstrap-complete
    reboot
  '';
in
{
  environment.systemPackages = bootstrapPkgs;
  systemd.services.bootstrap = {
    description = "bootstrap";
    path = bootstrapPkgs;
    serviceConfig = {
      Type = "simple";
      ExecStart = "${bootstrapScript}";
      Restart = "on-failure";
      PathExists = "!/var/lib/bootstrap-complete";
    };
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
  };
}

