{ pkgs, config, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      programs.mcfly = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
        enableFuzzySearch = true;
        keyScheme = "vim";
      };
    };
  };
}