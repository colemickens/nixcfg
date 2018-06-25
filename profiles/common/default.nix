{ config, lib, pkgs, ... }:

let
in
{
  nix.binaryCachePublicKeys = [ "nix-cache.chimera.cloud-1:oA96DtZQ2OgdqxZoBvJ4aTcdilDggvYBZBXUi979c1w=" ]; # TODO: replace with correct key
  nix.trustedBinaryCaches = [ "nix-cache.chimera.cloud" ];

  nix.trustedUsers = [ "root" "cole" "@wheel" ];

  imports = [ ./yubikey-gpg.nix ];

  nixpkgs.config ={
    allowUnfree = true;
  };

  boot.kernel.sysctl = {
    "fs.inotify.max_user_instances" = 256;
    "fs.inotify.max_user_watches" = 500000;
  };
  boot.tmpOnTmpfs = true;
  boot.cleanTmpDir = true;
  boot.supportedFilesystems = [ "btrfs" ];

  virtualisation = {
    docker.enable = true;
    rkt.enable = true;
    libvirtd.enable = true;
  };

  # common services
  services = {
    avahi = {
      enable = true;
      nssmdns = true;
      publish = {
        enable = true;
        userServices = true;
        addresses = true;
        hinfo = true;
      };
    };
    locate.enable = true;
    openssh = {
      enable = true;
      passwordAuthentication = false;
      permitRootLogin = "no";
    };
    timesyncd.enable = true;
    upower.enable = true;
  };

    # gpg/ssh
  services.pcscd.enable = true;
  programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # user management
  users.mutableUsers = false;
  security.sudo.wheelNeedsPassword = false;

  # NON-GUI APPS ONLY.
  environment.systemPackages = with pkgs ; [
    nox

    zsh bash tmux
    wget curl stow
    openssh autossh mosh sshuttle
    htop iotop
    fzy ripgrep jq
    keybase
    git cvs git tig mercurial subversion #darcs
    git-hub gist

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
    usbutils

    aria2 megatools youtube-dl
    pipes

    wimlib
    #networkmanager-wireguard

    iptables
    flameshot
  ];
}

