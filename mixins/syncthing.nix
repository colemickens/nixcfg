{ config, pkgs, inputs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      services.syncthing = {
        enable = true;
        tray = {
          enable = true;
        };
      };
    };
  };
}

