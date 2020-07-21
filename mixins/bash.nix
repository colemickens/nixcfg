{ pkgs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      programs.bash = {
        enable = true;
      };
    };
  };
}
