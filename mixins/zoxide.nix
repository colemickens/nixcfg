{ ... }:

{
  config = {
    home-manager.users.cole =
      { pkgs, ... }@hm:
      {
        programs.zoxide = {
          enable = true;
        };
      };
  };
}
