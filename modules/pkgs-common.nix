{ pkgs, ...}:

{
  # bare minimum applications I expect to be available on ALL machines
  # regardless of profile-*/pkgs-* inclusion:
  environment.systemPackages = with pkgs; [
    bc
    tmux
    bash bashCompletion
    zsh antibody
    wget curl
    ripgrep jq
    wget curl stow
    git-crypt gopass
    gnupg
    jq ripgrep fzf
    openssh autossh mosh sshuttle
    bat ncdu tree exa
    git gitAndTools.hub gist tig
    # cvs mercurial subversion pijul
    neovim vim
    htop iotop which binutils.bintools stow
    p7zip unrar parallel unzip xz zip

    gomuks
  ];
}
