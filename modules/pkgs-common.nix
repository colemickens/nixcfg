{ pkgs, ...}:

let
  cachixpkgs = import (builtins.fetchTarball { url = "https://cachix.org/api/v1/install"; }) {};
in
{
  environment.systemPackages = [] ++
    (with cachixpkgs; [
      cachix
    ]) ++

    (with pkgs; [
      bc
      broot
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
      gitAndTools.gitFull gitAndTools.hub gist tig
      cvs mercurial subversion # pjiul
      nix-prefetch
      neovim vim
      htop iotop which binutils.bintools stow
      p7zip unrar parallel unzip xz zip
    ]);
}
