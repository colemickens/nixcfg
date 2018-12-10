{ pkgs, ... }:

{
  environment.systemPackages = with pkgs ; [
    zsh bash bashCompletion tmux
    vim neovim
    wget curl stow kubectl
    openssh autossh mosh sshuttle
    htop iotop
    fzy ripgrep jq
    keybase
    git cvs git tig mercurial subversion darcs
    pijul
    gitAndTools.hub gist

    cifs-utils
    efibootmgr cryptsetup

    cmake gnumake
    p7zip unrar parallel unzip xz zip

    go rustup
    binutils.bintools

    aria2 megatools youtube-dl plowshare

    bind
    file
    ffmpeg
    fswatch
    gist
    gnupg
    gptfdisk
    less
    lsof
    ms-sys
    ntfs3g
    openssl
    parted
    pciutils
    peco
    pmtools
    powertop
    psmisc
    stow
    tree
    which
    fzf gdb wipe dmidecode
    qrencode zbar highlight
    ranger
  ];
}

