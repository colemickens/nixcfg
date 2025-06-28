{ ... }:

{
  config = {
    home-manager.users.cole =
      { pkgs, ... }:
      {
        programs.bottom = {
          enable = true;
          # settings = {};
        };
      };
  };
}
