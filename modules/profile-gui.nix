{ config, lib, pkgs, ... }:

with lib;

{
  imports = [
    ./mixin-firefox.nix
  ];
  config = { 
    hardware.pulseaudio.enable = true;
    nixpkgs.config.pulseaudio = true;

    programs = {
      light.enable = true;
    };

    services = {
      flatpak.enable = true;
    };

    fonts = {
      fonts = with pkgs; [
        corefonts inconsolata awesome
        fira-code fira-code-symbols fira-mono
        source-code-pro
        noto-fonts noto-fonts-emoji
        nerdfonts
      ];
    };

    environment.systemPackages = with pkgs; [
      arc-theme numix-icon-theme numix-icon-theme-circle

      ark
      #chromiumDev
      dolphin
      discord
      evince
      falkon
      feh
      gimp
      google-chrome-dev
      kate
      kitty
      #konqueror
      libinput
      libinput-gestures
      pavucontrol
      ripasso
      spotify
      streamlink
      termite
      transmission
      vlc
      vscode
      xclip

      gnome3.gedit
      gnome3.gnome-tweaks
      gnome3.nautilus
      gnome3.file-roller
    ];
  };
}

