{ config, pkgs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      programs.obs-studio = {
        enable = true;
        plugins = with pkgs; [
          obs-wlrobs
          obs-v4l2sink
        ];
      };
    };
  };
}
