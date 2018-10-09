#!nix
{ config, lib, pkgs, ... }:

let
  device = "packet-kube";
  mypkgs = with pkgs; [ bash curl git nix tmux gnutar sudo ];
in
{
  environment.systemPackages = mypkgs;
  systemd.services.bootstrap-nixos = {
    description = "NixOS Bootstrap";
    path = mypkgs;
    serviceConfig = {
      Type = "simple";
      ExecStart = "${bootstrapScript}";
      ExecStart = pkgs.writeScript "bootstrap.sh" ''
        #!/usr/bin/env bash
        set -x
        until curl --output /dev/null --silent --head --fail \
          "https://raw.githubusercontent.com/colemickens/nixcfg/master/utils/prep-machine.sh" \
            > /tmp/bootstrap.sh ; do sleep 5; done
        chmod +x /tmp/bootstrap.sh
        /tmp/bootstrap.sh "${device}"
      '';
     Restart = "on-failure";
    };
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
  };
}

