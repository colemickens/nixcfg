{ pkgs, ... }:

{
  config = {
    environment.pathsToLink = [ "/share/zsh" ];

    home-manager.users.cole = { pkgs, ... }: {
      programs.zsh = {
        enable = true;
        enableAutosuggestions = true;
        enableCompletion = true;
        dotDir = ".config/zsh";
        shellAliases = {
          "ls" = "ls --color --group-directories-first";
        };

        # TODO:
        # - reverse search w/ fzf
        # - tab-completion isn't color-highlighted
        # - can rev search + tab-completion use the same tool/path?


        envExtra = ''
          # commands added to .zshenv
        '';

        initExtra = ''
          # added to .zshrc
          # executed in login+interactive+ssh (I think)
          bindkey -e

          # surely something else has these defaults?
          bindkey "^[[H"    beginning-of-line
          bindkey "^[[F"    end-of-line
          bindkey "^[[3~"   delete-char
          bindkey "^[[1;5C" forward-word
          bindkey "^[[1;5D" backward-word

          bindkey '\ec' fzy-cd-widget
          bindkey '^T'  fzy-file-widget
          bindkey '^R'  fzy-history-widget
          bindkey '^P'  fzy-proc-widget

          zstyle :fzy:tmux    enabled      yes

          # autoload -U compinit && compinit
        '';

        plugins = [
          {
            name = "powerlevel10k-config";
            src = pkgs.substituteAll { src=./zsh-p10k.zsh; dir="bin"; };
            file = "bin/zsh-p10k.zsh";
          }
          {
            name = "powerlevel10k";
            src = pkgs.zsh-powerlevel10k;
            file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
          }
          {
            name = "zsh-fast-syntax-highlighting";
            src = pkgs.zsh-fast-syntax-highlighting;
            file = "share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh";
          }
          {
            name = "zsh-fzy";
            src = pkgs.zsh-fzy;
            file = "share/zsh/plugins/zsh-fzy/zsh-fzy.plugin.zsh";
          }
          # nix-zsh-completions <- doesn't support flakes (yet) anyway: https://github.com/spwhitt/nix-zsh-completions/issues/32
          # zsh-completions
        ];

        # history = {
        #   #path = "${config.xdg.dataHome}/zsh/zsh_history";
        # };
        # initExtraBeforeCompInit = ''
        #   export TZSH_INIT_EXTRA_BEFORE_COMP_INIT=1
        # '';
        # loginExtra = ''
        #   # extra .zlogin
        #   export TZSH_LOGIN_EXTRA=1
        # '';
        # profileExtra = ''
        #   # extra .zprofile
        #   export TZSH_PROFILE_EXTRA=1
        # '';
        # sessionVariables = {
        #   TZSH_TEST_VAR = "VALUE";
        # };
        # gpg stuff
      };
    };
  };
}
