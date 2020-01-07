{ pkgs, ... }: 

let
  doBuild = pkgs.writeScript "doBuild.sh" ''
    #!/usr/bin/env bash
    cd /home/cole/code/overlays/nixpkgs-wayland
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
    path = with pkgs; [ bash curl jq gopass ];
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
