{ config, pkgs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      programs.skim = {
        enable = true;
        defaultOptions = [ "--height 60%" "--prompt" ];
        fileWidgetCommand = "fd --type f";
        fileWidgetOptions = [ "--preview 'bat --color always {}'" ];
        changeDirWidgetCommand = "fd --type d";
        changeDirWidgetOptions = [ "--preview 'eza --la | head -100'" ];
        enableBashIntegration = true;
        enableZshIntegration = true;
        enableFishIntegration = true;
      };
    };
  };
}
