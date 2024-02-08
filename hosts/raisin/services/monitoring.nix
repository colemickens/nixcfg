{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  config = {
    networking.firewall.allowedTCPPorts = [ 3000 ];

    services = {
      grafana = {
        enable = true;
        settings = {
          default = {
            instance_name = "grafana_raisin";
          };
          server = {
            http_addr = "0.0.0.0";
            http_port = 3000;
          };
        };
      };
    };
  };
}
