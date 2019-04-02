{ config, lib, pkgs, ... }:

with lib;

{
  config = {
    boot = {
      tmpOnTmpfs = true;
      cleanTmpDir = true;
      kernel.sysctl = {
        "fs.file-max" = 100000;
        "fs.inotify.max_user_instances" = 256;
        "fs.inotify.max_user_watches" = 500000;
      };
    };

    nixpkgs.overlays = [
      (pkgsself: pkgssuper: {
        libdrm = pkgssuper.libdrm.override {
        };
        mesa = pkgssuper.mesa.override {
        };
      })
    ];

    nix = {
      buildCores = 0;
      binaryCachePublicKeys = [
        #"nixcache.cluster.lol-1:DzcbPT+vsJ5LdN1WjWxJPmu+BeU891mgsrRa2X+95XM="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
      binaryCaches = [
        #"https://nixcache.cluster.lol"
        "https://cache.nixos.org"
      ];
      trustedUsers = [ "@wheel" "root" ];
    };

    # setup homedir using one of the various options:
    # TODO
    # - home-manager?
    
    # bare minimum applications I expect to be available on ALL machines
    # regardless of profile-*/pkgs-* inclusion:
    environment.systemPackages = with pkgs; [
      tmux
      bash bashCompletion
      zsh antibody
      wget curl
      ripgrep jq
      wget curl stow
      git-crypt gopass
      gnupg pinentry pinentry_gnome gnome3.gcr
      jq ripgrep fzf
      openssh autossh mosh sshuttle
      bat ncdu tree exa
      git gitAndTools.hub gist tig
      # cvs mercurial subversion pijul
      neovim vim
      htop iotop which binutils.bintools stow
      p7zip unrar parallel unzip xz zip

      (callPackage ../pkgs/gitstatus {})
    ];

    # locale stuff
    i18n = {
      consoleKeyMap = "us";
      defaultLocale = "en_US.UTF-8";
    };

    # gpg stuff
    services.pcscd.enable = true;
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      enableExtraSocket = true;
    };
    programs.ssh.startAgent = false;

    # setup 'cole' and block others users
    security.sudo.wheelNeedsPassword = false;
    users.mutableUsers = false;
    users.extraGroups."cole".gid = 1000;
    users.extraUsers."cole" = {
      isNormalUser = true;
      home = "/home/cole";
      description = "Cole Mickens";
      #mkpasswd -m sha-512
      hashedPassword = "$6$k.vT0coFt3$BbZN9jqp6Yw75v9H/wgFs9MZfd5Ycsfthzt3Jdw8G93YhaiFjkmpY5vCvJ.HYtw0PZOye6N9tBjNS698tM3i/1";
      shell = "/run/current-system/sw/bin/zsh";
      extraGroups = [ "wheel" "networkmanager" "kvm" "libvirtd" "docker" "transmission" "audio" "video" "sway" "sound" "pulse" "input" "render" ];
      uid = 1000;
      group = "cole";
    };
  };
}

