{ config, lib, pkgs, ... }:

with lib;

{
  config = {
    # bare minimum applications I expect to be available:
    environment.systemPackages = with pkgs; [ bash tmux git neovim htop ripgrep jq gopass gnupg ];
    nix.trustedUsers = [ "cole" ];

    i18n = {
      consoleKeyMap = "us";
      defaultLocale = "en_US.UTF-8";
    };

    services = {
      pcscd.enable = true;
    };

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      enableExtraSocket = true;
    };

    programs.ssh.startAgent = false;

    users.extraGroups."cole".gid = 1000;
    users.extraUsers."cole" = {
      isNormalUser = true;
      home = "/home/cole";
      description = "Cole Mickens";
      #mkpasswd -m sha-512
      hashedPassword = "$6$gYyrDUSf9hL4H$CWQFdAu1N1EfMIGg3eZhn.YM83VN/Blsbtxh9MW6z0PHVFSGaHX0McJmKHVmeFEnve6gS5l302fZzR0xsSR0t1";
      shell = "/run/current-system/sw/bin/bash";
      extraGroups = [ "wheel" "networkmanager" "kvm" "libvirtd" "docker" "transmission" "audio" "video" "sway" "sound" "pulse" "input" "render" ];
      uid = 1000;
      group = "cole";
    };
  };
}

