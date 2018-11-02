{ pkgs, ... }:

{
  environment.systemPackages = with pkgs ; [
    zsh bash tmux
    wget curl stow
    openssh fzf fzy jq ripgrep
    git cvs git tig mercurial subversion darcs
    gitAndTools.hub gist
    vim neovim
    htop tree which binutils.bintools
    efibootmgr parted cryptsetup
    p7zip unrar parallel unzip xz zip
    aria2 megatools youtube-dl plowshare
    dmidecode
    ranger
    ffmpeg
  ];
}

