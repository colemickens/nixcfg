{ config, pkgs, ... }:

{
  options = {
    # enable
    # nr tests?
    # timer config
  };

  config = {
    systemd = {
      services."cfspeedtest" = {
        script = ''
        '';
      };
      timers."cfspeedtest" = { };
    };
    services = {
      nginx = {
        enable = true;
        # openFirewall?
        # just on a single port
        # expose to tailscale
      };
    };
    # nginx to serve files?
  };
}
