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
      # firefox comes from the mixin/overlay
      #google-chrome
      google-chrome-dev
      epiphany
      qtpass
      #chromiumCanary

      arc-theme numix-icon-theme numix-icon-theme-circle
      gimp graphviz inkscape feh
      discord
      vlc
      pavucontrol
      spotify transmission
      vscode kate gnome3.gedit
      slack signal-desktop zoom-us

      termite kitty

      ark dolphin
      evince
      gnome3.gnome-tweaks
      gnome3.nautilus
      gnome3.file-roller

      libinput libinput-gestures
      browserpass
      xclip
      discord
    ];
  };
}

