{ config, pkgs, ... }:

let
  cfg = config.innnernet;
in {
  options = {
    # enable = mkEnable
    # ...
  };

  config = {

    systemd.services.innernet-client-mynet = {
      description = "innernet client";
    };

    systemd.services.innernet-server-mynet = {
      description = "innernet server for mynet";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" "nss-lookup.target" ];
      wants = [ "network-online.target" "nss-lookup.target" ];
      path = with pkgs; [ iproute ];
      environment = { RUST_LOG = "info"; };
      serviceConfig = {
        Restart = "always";
        ExecStart = "${unstable.innernet}/bin/innernet-server serve mynet";
      };
    };

  };
}
