{
  config,
  pkgs,
  inputs,
  ...
}:

{
  config = {
    # https://docs.syncthing.net/users/firewall.html
    networking.firewall.allowedTCPPorts = [ 22000 ];
    networking.firewall.allowedUDPPorts = [
      22000
      21027
    ];

    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 8384 ];

    home-manager.users.cole =
      { pkgs, ... }@hm:
      {
        services.syncthing = {
          enable = true;
          extraOptions = [
            "--config=${hm.config.xdg.configHome}/syncthing"
            "--data=${hm.config.xdg.dataHome}/syncthing"
          ];
          # tray.enable = true;
        };
      };
  };
}
