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
      fontconfig = {
        defaultFonts = {
          monospace = ["Liberation Mono"];
          sansSerif = ["Liberation Sans"];
          serif = ["Liberation Serif"];
        };
        # localConf = []; ? 
      };
      fonts = with pkgs; [
        corefonts inconsolata awesome
        overpass
        fira-code fira-code-symbols fira-mono
        source-code-pro
        noto-fonts noto-fonts-extra noto-fonts-emoji
        ttf_bitstream_vera
        gelasio
      ];
    };

    environment.systemPackages = with pkgs; [
      riot-desktop
      imgurbash2 # move?
      nix-prefetch # move? # is there a better one?
      openssl # lol wat move
      spectral
      fractal
      freerdp
      calibre
      okular # TODO: pulls in qt?

      rdesktop

      qt5.qtwayland
      qt5.qtbase
      lxappearance
      numix-icon-theme
      breeze-qt5 # needed for breeze cursor # TODO: pulls in qt?

      libva-utils
      xdg_utils

      brightnessctl
      chromiumOzone
      google-chrome-dev
      evince
      feh
      gimp
      mpv
      pavucontrol
      spotify
      termite
      vscodium
      lm_sensors
    ];
  };
}
