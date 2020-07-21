{ pkgs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      programs.mako = {
        enable = true;
      };
    };
  };
}

