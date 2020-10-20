{ config, pkgs, inputs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      programs.htop = {
        enable = true;
        showProgramPath = false;
      };
    };
  };
}
