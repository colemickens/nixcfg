{ config, pkgs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      programs.skim = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
        enableFishIntegration = true;
      };
    };
  };
}
