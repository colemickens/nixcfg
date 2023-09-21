{ pkgs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      programs.fish = {
        enable = true;
        #interactiveShellInit = ''
        shellInit = ''
          set -Ua fish_user_paths /home/cole/code/nixcfg
        '';
        shellAliases = {
          "ls" = "ls --color --group-directories-first";
        };
        #plugins = [
        # # bax instead?
        #  pkgs.fishPlugins.foreign-env

        # jethrokuan/fzf

        #  acomagu/fish-async-prompt
        #];
      };
    };
  };
}
