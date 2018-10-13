{ config, lib, pkgs, ... }:

let
  apkgs = (import <nixpkgs> {
    overlays = [(import /etc/nixos/azure-cli-nix/default.nix)];
  });
in
{
  imports = [ ./yubikey-gpg.nix ];

  nix = {
    # TODO: why is this not working with nixos-rebuild swithc locally to pul lfro mthese?
    # --> I have to use the full command line...?
    binaryCachePublicKeys = [
      "nix-cache.cluster.lol-1:Pa4IudNcMNF+S/CjNt5GmD8vVJBDf8mJDktXfPb33Ak="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
    trustedBinaryCaches = [
      "https://kixstorage.blob.core.windows.net/nixcache"
      "https://cache.nixos.org"
    ];
    binaryCaches = [
      "https://kixstorage.blob.core.windows.net/nixcache"
      "https://cache.nixos.org"
    ];
    trustedUsers = [ "root" "cole" "@wheel" ];
  };

  nixpkgs.config ={
    allowUnfree = true;
  };

  boot = {
    tmpOnTmpfs = true;
    cleanTmpDir = true;
    supportedFilesystems = [ "btrfs" ];
    kernel.sysctl = {
      "fs.file-max" = 100000;
      "fs.inotify.max_user_instances" = 256;
      "fs.inotify.max_user_watches" = 500000;
    };
  };

  services = {
    timesyncd.enable = true;
    pcscd.enable = true;
    upower.enable = true;
  };

  users.mutableUsers = false;
  security.sudo.wheelNeedsPassword = false;

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

    apkgs.python36Packages.azure-cli
    azure-storage-azcopy

    yad
    ranger
    pinentry

    bluez
  ];
}

