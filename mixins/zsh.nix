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
          # path+=/home/cole/code/nixcfg # moved to init (since it wasnt in ssh sessions)
        '';
        
        initExtra = ''
          # added to .zshrc
          bindkey -e
          path+=/home/cole/code/nixcfg
        '';

        plugins = [
          {
            name = "powerlevel10k-config";
            src = pkgs.substituteAll { src=./zsh-p10k.zsh; dir="bin"; };
            file = "bin/zsh-p10k.zsh";
            
            # doesn't work ?
            # src = ./zsh-p10k.zsh;
            # file = "./zsh-p10k.zsh";
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