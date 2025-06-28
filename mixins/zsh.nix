{ ... }:

{
  config = {
    environment.pathsToLink = [ "/share/zsh" ];
    programs.zsh.enable = true;

    home-manager.users.cole =
      { pkgs, ... }@hm:
      {
        programs.zsh = {
          enable = true;
          autosuggestion.enable = true;
          enableCompletion = true;
          defaultKeymap = "viins";
          dotDir = ".config/zsh";
          shellAliases = {
            "ls" = "ls --color --group-directories-first";
            "exa" = "exa --group-directories-first";
          };
          history = {
            size = 99999;
            save = 99999;
            path = "${hm.config.xdg.dataHome}/zsh/zsh_history";
          };

          envExtra = ''
            export KEYTIMEOUT=10
            export MCFLY_RESULTS_SORT="LAST_RUN"
            export LESSHISTFILE=-

            # SESSION
            ${
              "" # hm.config.lib.shell.exportAll config.environment.sessionVariables
            }

            # HM SESSION
            ${
              "" # hm.config.lib.shell.exportAll hm.config.home.sessionVariables
            }
          '';

          initContent = ''
            bindkey "^[[H"    beginning-of-line
            bindkey "^[[F"    end-of-line
            bindkey "^[[3~"   delete-char
            bindkey "^[[1;5C" forward-word
            bindkey "^[[1;5D" backward-word
          '';

          plugins = [ ];
        };
      };
  };
}
