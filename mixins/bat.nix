{ pkgs, ... }:

{
  config = {
    home-manager.users.cole =
      { pkgs, ... }:
      {
        programs.bat = {
          enable = true;
          config = {
            theme = "TwoDark";
          };
        };
      };
  };
}
