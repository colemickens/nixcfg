{ pkgs, config, ... }:

{
  config = {
    services.tailscale.enable = true;

    boot.kernel.sysctl."net.ipv4.conf.all.forwarding" = true;

    networking.firewall.trustedInterfaces = [ "tailscale0" ];
  }
    #  // (if config.networking.hostName != "jeffhyper" then {} else {
    #   systemd.services.tailscale.serviceConfig.Environment = [
    #     "PORT=${config.services.tailscale.port}"
    #     "FLAGS=--exit-node=192.168.1.200"
    #   ];
    # })
  ;
}
