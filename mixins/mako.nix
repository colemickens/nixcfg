{ pkgs, ... }:

{
  config = {
    home-manager.users.cole =
      { pkgs, ... }:
      {
        services.mako = {
          enable = true;
        };
      };
  };
}
