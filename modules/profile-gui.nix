{ config, lib, pkgs, ... }:

with lib;

let
  ncw = import /etc/nixpkgs-chromium-wayland {};
  # why does this not work?
  chromiumOzone = ncw.chromium.override {
    channel = "dev";
    useOzone = true;
    enablePepperFlash = true;
    enableWideVine = true;
  };
in
{
  imports = [
    ./mixin-firefox.nix
  ];
  config = { 
    hardware.pulseaudio.enable = true;
    nixpkgs.config.pulseaudio = true;

    hardware.brightnessctl.enable = true;

    services = {
      flatpak.enable = true;
    };

    fonts = {
      fonts = with pkgs; [
        corefonts inconsolata awesome
        fira-code fira-code-symbols fira-mono
        source-code-pro
        twemoji-color-font
        noto-fonts noto-fonts-extra noto-fonts-emoji
        ttf_bitstream_vera
        nerdfonts
      ];
    };

    environment.systemPackages = with pkgs; [
      arc-theme numix-icon-theme numix-icon-theme-circle

      passff-host

      alacritty
      ark
      #chromiumOzone
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
      mpv
      pavucontrol
      plex-media-player
      spotify
      streamlink
      termite
      transmission
      vscode
      xclip

      gnome3.gedit
      gnome3.gnome-tweaks
      gnome3.nautilus
      gnome3.file-roller

      qt5.qtwayland
    ];
  };
}

