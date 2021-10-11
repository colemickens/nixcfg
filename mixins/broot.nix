{ pkgs, config, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      programs.broot = {
        enable = true;

        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
      };
    };
  };
}