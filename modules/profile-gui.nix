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
      #enableFontDir = true;
      #enableGhostscriptFonts = true;
      fonts = with pkgs; [
        corefonts inconsolata awesome
        fira-code fira-code-symbols fira-mono
        source-code-pro
        noto-fonts noto-fonts-emoji
        nerdfonts
      ];
    };

    environment.systemPackages = with pkgs; [
      # NOTE: firefox comes from the mixin

      arc-theme numix-icon-theme numix-icon-theme-circle
      chromium google-chrome
      gimp graphviz inkscape # TODO: add basic image viewer? todo: whats a good one?
      vlc mpv
      libva libva-full libva-utils
      pavucontrol
      spotify transmission
      vscode kate gnome3.gedit
      slack signal-desktop zoom-us

      ark dolphin
      evince
      gnome3.gnome-tweaks
      gnome3.nautilus
      gnome3.file-roller

      libinput libinput-gestures
    ];
  };
}

