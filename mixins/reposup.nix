{ config, pkgs, ... }:

{
  config = {
    programs.sway.enable = true; # needed for swaylock/pam stuff
    programs.sway.extraPackages = []; # block rxvt

    home-manager.users.cole = { pkgs, ... }: {  
      programs.reposup = {
        # so, this starts a user systemd service that monitors these directories
        # and keeps track of the configured state, vs what is actually happening
        enable = true;
        coderoots = {
          cole-code = {
            rootdir = "/home/cole/code";
            config = {
              repos = {
                autoport = {};
                azure-linux-boot-agent = {};
                blog = {};
                cyclops = {};
                flake-firefox-nightly = {};
                home-manager = {
                  multibranch = true;
                  upstreams = {};
                  branches = {
                    cmhm = {};
                  };
                };
                nixos-azure = {};
                wfvm = {};
              };
            };
          };
        };
      };
    };
  };
}
