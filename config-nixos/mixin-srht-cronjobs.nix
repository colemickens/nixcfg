{ pkgs, ... }: 

let
  doBuild = pkgs.writeScript "doBuild.sh" ''
    #! /usr/bin/env bash
    set -eu
    mkdir -p /tmp/overlaydir
    cd /tmp/overlaydir
    if [[ ! -d ./nixpkgs-wayland ]]; then
      git clone https://github.com/colemickens/nixpkgs-wayland
    fi
    cd nixpkgs-wayland
    git remote update
    git reset --hard origin/master
    bash .ci/srht-submit.sh
  '';
in
{
  systemd.timers.srht-nixpkgs-wayland = {
      wantedBy = [ "timers.target" ];
      partOf = [ "srht-nixpkgs-wayland.service" ];
      timerConfig.OnCalendar = "hourly";
  };

  systemd.services.srht-nixpkgs-wayland = {
    path = with pkgs; [ bash curl jq gopass git ];
    #wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    description = "...";
    serviceConfig = {
      Type = "simple";
      User = "cole";
      ExecStart = ''${doBuild}'';
    };
  };
}
