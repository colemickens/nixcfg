{ config, lib, pkgs, ... }:

with lib;

let
  ncw = import /etc/nixpkgs-chromium-wayland {};
  # why does this not work?
  chromiumOzone = ncw.chromium.override {
    channel = "dev";
    useOzone = true;
    enablePepperFlash = true;
    #enableWideVine = true;
  };
in
{
  imports = [
    ./mixin-firefox.nix
  ];
  config = { 
    hardware = {
      brightnessctl.enable = true;
      opengl = {
        enable = true;
        extraPackages = with pkgs; [
          vaapiIntel
          vaapiVdpau libvdpau-va-gl
        ];
      };
      pulseaudio.enable = true;
    };
    nixpkgs.config.pulseaudio = true;
    nixpkgs.config.packageOverrides = pkgs: {
      vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
    };

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

      alacritty
      ark
      brightnessctl
      #chromiumOzone
      dolphin
      discord
      epiphany
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
      #obs-studio
      pavucontrol
      plex-media-player
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

      qt5.qtwayland
    ];
  };
}

