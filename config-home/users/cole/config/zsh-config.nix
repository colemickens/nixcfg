{ pkgs, ... }:

{
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
    #test
    path+=/home/cole/code/nixcfg
  '';
  
  initExtra = ''
    # added to .zshrc
    bindkey -e
  '';

  plugins = [
    {
      name = "powerlevel10k";
      src = pkgs.zsh-powerlevel10k;
      file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
    }
    {
      name = "powerlevel10k-config";
      src = pkgs.lib.cleanSource ./p10k-config;
      file = "p10k.zsh";
    }
    {
      name = "zsh-nix-shell";
      src = pkgs.zsh-nix-shell;
      file = "share/zsh-nix-shell/nix-shell.plugin.zsh";
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
}
