{ pkgs, config, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      programs.zoxide = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
      };
    };
  };
}