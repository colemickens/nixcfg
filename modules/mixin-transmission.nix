{
  networking.firewall.allowedTCPPorts = [ 9091 ];
  services = {
    transmission = {
      enable = true;
      port = 9091; # TODO: verify doesn't break
      settings = {
        rpc-whitelist = "127.0.0.1,192.168.*.*";
        umask = 2;
      };
    };
  };
}
