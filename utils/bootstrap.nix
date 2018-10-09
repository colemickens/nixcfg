#!nix
{ config, lib, pkgs, ... }:

let
  device = "packet-kube";
  mypkgs = with pkgs; [ bash curl git nix tmux gnutar sudo ];
  bootstrapScript = pkgs.writeScript "bootstrap.sh" ''
    #!/usr/bin/env bash
    set -x
    [[ ! -d /etc/nixcfg ]] && sudo git clone https://github.com/colemickens/nixcfg /etc/nixcfg
    cd /etc/nixcfg/utils
    ./bootstrap.sh
  '';
in
{
  environment.systemPackages = mypkgs;
  systemd.services.bootstrap-nixos = {
    description = "NixOS Bootstrap";
    path = mypkgs;
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

