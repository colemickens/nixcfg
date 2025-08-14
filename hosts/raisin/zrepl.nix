{
  config,
  pkgs,
  lib,
  ...
}:

{
  config = {
    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 8888 ];
    services.zrepl = {
      enable = true;
      settings = {
        jobs = [
          {
            name = "sink_origionraisin";
            type = "sink";
            root_fs = "orionraisinpool/backups";
            serve = {
              type = "tcp";
              listen = "100.112.194.64:8888";
              listen_freebind = true;
              clients = {
                # TODO: source from data/
                "100.93.96.66" = "zeph"; 
                "100.81.167.123" = "slynux";
              };
            };
          }
        ];
      };
    };
  };
}
