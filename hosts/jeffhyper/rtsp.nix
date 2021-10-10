{ config, pkgs, lib, ... }:

let
  configFile = pkgs.writeText "rstp.yml" (pkgs.lib.generators.toYAML {} {
    paths = (import ./cameras.nix);
  });
in {
  config = {
    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 8554 ];
    systemd.services.rtsp-simple-server = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        RestartSec = 10;
        Restart = "on-failure";
      };
      script = ''
        ${pkgs.rtsp-simple-server}/bin/rtsp-simple-server "${configFile}"
      '';
    };
  };
}
