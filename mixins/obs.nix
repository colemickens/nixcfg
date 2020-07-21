{ config, pkgs, ... }:

{
  config = {
    programs.sway.enable = true; # needed for swaylock/pam stuff
    programs.sway.extraPackages = []; # block rxvt

    home-manager.users.cole = { pkgs, ... }: {  
      programs.obs-studio = {
        enable = true;
        plugins = with pkgs; [ obs-wlrobs obs-v4l2sink ];
      };
    };
  };
}
