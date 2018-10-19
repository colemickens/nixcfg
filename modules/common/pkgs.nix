{ pkgs, ... }:

{
  environment.systemPackages = with pkgs ; [
    nox

    zsh bash tmux
    wget curl stow
    openssh autossh mosh sshuttle
    htop iotop
    fzy ripgrep jq
    keybase
    git cvs git tig mercurial subversion darcs
    pijul
    gitAndTools.hub gist

    cifs-utils

    vim neovim

    kubectl awscli google-cloud-sdk
    azure-vhd-utils # azure-cli
    nixopsUnstable

    efibootmgr
    cryptsetup

    cmake gnumake
    p7zip unrar parallel unzip xz zip

    asciinema
    imgurbash2

    bind
    file
    ffmpeg
    fswatch
    gcc
    gettext
    gist
    gnupg
    gptfdisk
    gotty
    httpie
    ipfs
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
    qrencode
    slop
    smbclient
    stow
    sqlite
    telnet
    traceroute
    tree
    valgrind
    weechat
    which
    wireguard
    wireguard-tools
    usbutils

    aria2 megatools youtube-dl
    pipes

    wimlib
    #networkmanager-wireguard

    iptables
    flameshot
    jsonnet
    ksonnet
    patchelf

    nodejs
    python2nix
    minikube
    ipvsadm
    rustup
    yarn
    binutils.bintools
    wipe
    go
    nodePackages.dat
    #nodePackages.beaker-browser

    dmidecode

    # python
    #python3
    #python36Packages.toolz
    #python36Packages.pip
    python

    # nix related
    go2nix

    # cloud
    packet
    # for now install with nix-env -i until it's upstream
    #nodePackages.cloudflare-cli
    dep2nix

    python36Packages.azure-cli
    azure-storage-azcopy

    yad
    ranger
    pinentry

    bluez
    fzf

    gdb
    plowshare
  ];
}

