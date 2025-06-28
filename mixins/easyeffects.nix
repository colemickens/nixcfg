{ ... }:

{
  config = {
    home-manager.users.cole =
      { pkgs, ... }:
      {
        services.easyeffects = {
          enable = true;
        };
      };
  };
}
