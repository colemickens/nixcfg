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
        plugins = [
          # bax instead?
          {name="fish-foreign-env"; src=pkgs.fish-foreign-env.src;}

          # jethrokuan/fzf

          #  acomagu/fish-async-prompt 
        ];
      };
    };
  };
}