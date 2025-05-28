{ pkgs, config, ... }:

{
  config = {
    environment.pathsToLink = [ "/share/zsh" ];

    # BUG: come onnnnn nixpkgs
    programs.zsh.enable = true;
    # users.users.cole.ignoreShellProgramCheck = true;

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

          # TODO:
          # - tab-completion isn't color-highlighted
          # - can rev search + tab-completion use the same tool/path?
          # - better nix/lorri/direnv integration?

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

          # replace initExtra with initContent,
          # but uh, I don't use this anyway?
          # maybe time to drdop this entirely?
          initExtra = ''
            bindkey "^[[H"    beginning-of-line
            bindkey "^[[F"    end-of-line
            bindkey "^[[3~"   delete-char
            bindkey "^[[1;5C" forward-word
            bindkey "^[[1;5D" backward-word
          '';

          plugins = [
            # {
            #   name = "powerlevel10k-config";
            #   src = pkgs.substituteAll {
            #     src = ./zsh-p10k.zsh;
            #     dir = "bin";
            #   };
            #   file = "bin/zsh-p10k.zsh";
            # }
            # {
            #   name = "powerlevel10k";
            #   src = pkgs.zsh-powerlevel10k;
            #   file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
            # }
            # {
            #   name = "zsh-fast-syntax-highlighting";
            #   src = pkgs.zsh-fast-syntax-highlighting;
            #   file = "share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh";
            # }
          ];

          # initExtraBeforeCompInit = ''
          #   export TZSH_INIT_EXTRA_BEFORE_COMP_INIT=1
          # '';
          # loginExtra = ''
          profileExtra = ''
            if [[ "''${AUTOLOGIN_CMD}" != "" ]]; then
            (
              if [[ "$(tty)" == "/dev/tty1" ]]; then
                set -x
                "''${AUTOLOGIN_CMD}"
                exit
              fi
              )
            fi
          '';
          #   # extra .zprofile
          #   export TZSH_PROFILE_EXTRA=1
          # '';
          # sessionVariables = {
          #   TZSH_TEST_VAR = "VALUE";
          # };
        };
      };
  };
}
