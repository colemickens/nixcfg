#!nix
{ config, lib, pkgs, ... }:

let
  device = "packet-kube";
  mypkgs = with pkgs; [ bash curl git nix tmux gnutar ];
  bootstrapScript = pkgs.writeScript "bootstrap.sh" ''
    #!/usr/bin/env bash
    set -x
    set -euo pipefail

    # TODO: is this needed after the other mitigation??
    until $(curl --output /dev/null --silent --head --fail https://cache.nixos.org); do
      printf '.'; sleep 5
    done

    if [[ ! -d /etc/nixcfg ]]; then
      git clone https://github.com/colemickens/nixcfg /etc/nixcfg
      cd /etc/nixcfg
      git remote set-url origin "git@github.com:colemickens/nixcfg.git"
    fi

    cd /etc/nixcfg/utils
    ./prep-machine.sh "${device}"
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
  

  nix = {
    binaryCaches = [ https://kixstorage.blob.core.windows.net/nixcace https://cache.nixos.org ];
    trustedBinaryCaches = [ https://kixstorage.blob.core.windows.net/nixcace https://cache.nixos.org ];
    binaryCachePublicKeys = [
      "nix-cache.cluster.lol-1:Pa4IudNcMNF+S/CjNt5GmD8vVJBDf8mJDktXfPb33Ak="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
    nixPath = [
      "/etc/nixos"
      "nixpkgs=/etc/nixpkgs"
      "nixos-config=/etc/nixos/configuration.nix"
    ];
  };
}

