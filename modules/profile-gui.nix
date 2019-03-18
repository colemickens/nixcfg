{ config, lib, pkgs, ... }:

with lib;

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
          intel-media-driver
          vaapiIntel
          vaapiVdpau
          libvdpau-va-gl
        ];
        driSupport32Bit = true;
      };
      pulseaudio.enable = true;
    };
    nixpkgs.config.pulseaudio = true;
    nixpkgs.config.packageOverrides = pkgs: {
      vaapiIntel = pkgs.vaapiIntel.override {
        enableHybridCodec = true;
      };
    };

    #services = {
    #  flatpak.enable = true;
    #};

    fonts = {
      fonts = with pkgs; [
        corefonts inconsolata awesome
        overpass
        fira-code fira-code-symbols fira-mono
        source-code-pro
        twemoji-color-font
        noto-fonts noto-fonts-extra noto-fonts-emoji
        ttf_bitstream_vera
        nerdfonts
      ];
    };

    environment.systemPackages = with pkgs; [
#      arc-theme
#      numix-icon-theme
#      numix-icon-theme-circle

      libva-utils
      xdg_utils

      #alacritty
      #ark
      brightnessctl
      (chromium.override {
        channel = "dev";
        useVaapi = false;
        useOzone = true;
      })
      #dolphin
      discord
      evince
      feh
      gimp
      google-chrome-dev
      #kitty
      #libinput
      #libinput-gestures
      mpv
      pavucontrol
      #plex-media-player
      spotify
      termite
      #vlc
      vscode

      #gnome3.gnome-tweaks
      #gnome3.nautilus
      #gnome3.file-roller

      # not sure what needs this?
      #qt5.qtwayland
    ];
  };
}
