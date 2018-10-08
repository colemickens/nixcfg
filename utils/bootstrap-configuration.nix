#!nix
{ config, lib, pkgs, ... }:

let
  device = "packet-kube";
  mypkgs = with pkgs; [ bash curl git nix tmux gnutar ];
in
{
  environment.systemPackages = mypkgs;
  systemd.services.bootstrap-nixos = {
    description = "NixOS Bootstrap";
    path = mypkgs;
    serviceConfig = {
     Type = "simple";
     ExecStart = "/etc/bootstrap-nixos.sh";
     Restart = "on-failure";
    };
    unitConfig = {
      # ensure we only run once
      ConditionPathExists = "!/var/lib/bootstrap-complete";
    };
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
  };
  

  nix = {
    trustedBinaryCaches = [
      https://kixstorage.blob.core.windows.net/nixcache
      https://cache.nixos.org
    ];
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

  environment.etc."bootstrap-nixos.sh"= {
    mode = "0755";
    text = ''
      #!/usr/bin/env bash
      set -x
      set -euo pipefail

      # TODO: ugly spof, 
      until $(curl --output /dev/null --silent --head --fail https://cache.nixos.org); do
        printf '.'
        sleep 5
      done

      # TODO: move this vvv
      # TODO: declarative git repo management / my other idea gitbgsync
      # TODO: prototype + blog

      # the config we link into place expects the azure-cli overlay
      # this is temporary, hopefully... :/
      if [[ ! -d /etc/nixos/azure-cli-nix ]]; then
        git clone https://github.com/stesie/azure-cli-nix /etc/nixos/azure-cli-nix
      fi
      if [[ ! -d /etc/nixpkgs ]]; then
        git clone https://github.com/colemickens/nixpkgs /etc/nixpkgs
        cd /etc/nixpkgs
        git checkout kata3
        git remote set-url origin "git@github.com:colemickens/nixpkgs.git" # TODO: remove this
      fi

      if [[ ! -d /etc/nixcfg ]]; then
        git clone https://github.com/colemickens/nixcfg /etc/nixcfg
        cd /etc/nixcfg
        git remote set-url origin "git@github.com:colemickens/nixcfg.git" # TODO: remove this?
      fi

      if [[ ! -f "/etc/nixos/configuration-original.nix" ]]; then
        mv /etc/nixos/configuration.nix "/etc/nixos/configuration-original.nix" || true
      fi
      rm -f /etc/nixos/configuration.nix
      ln -s /etc/nixcfg/devices/${device}/configuration.nix /etc/nixos/configuration.nix

      # TODO: remove (or find more elegant nix-y way to import my normal nixcfg, (which should actually be not that hard)
      # TODO: would be very cool blog post, actually. totally could login as my normal user and have all of my softawre without even thinkng about it
      # TODO: demo:
      #       - docker container, with my user+config
      #       - vm, same thing
      #       etc
      cat <<EOF >/root/.gitconfig
      [user]
        email = cole.mickens@gmail.com
        name = Cole Mickens
      EOF

      # TODO: blog post about the azure storage for massive cheap speedup
      export NIX_PATH=nixpkgs=/etc/nixpkgs:nixos-config=/etc/nixos/configuration.nix
      export NIXOSRB="$(nix-instantiate --eval -E '<nixpkgs>')/nixos/modules/installer/tools/nixos-rebuild.sh"
      export NIXOSRB="$(nix-build --no-out-link --expr 'with import <nixpkgs/nixos> {}; config.system.build.nixos-rebuild')/bin/nixos-rebuild";
      "''${NIXOSRB}" boot \
        --option extra-binary-caches \
        "https://kixstorage.blob.core.windows.net/nixcache https://cache.nixos.org https://hydra.nixos.org" \
        --option trusted-public-keys \
        "nix-cache.cluster.lol-1:Pa4IudNcMNF+S/CjNt5GmD8vVJBDf8mJDktXfPb33Ak= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="

      echo "done" > /var/lib/bootstrap-complete
      reboot
    '';
    };
  }

