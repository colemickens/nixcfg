{ pkgs, ... }:

{
  config = {
    home-manager.users.cole =
      { pkgs, ... }:
      {
        services.mako = {
          enable = true;
          systemd.enable = true;
        };
      };
  };
}
