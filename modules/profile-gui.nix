{ config, lib, pkgs, ... }:

with lib;

let
  iris = (pkgs.mesa.override {
    galliumDrivers = [
      "r300" "r600" "radeonsi" "nouveau" "virgl" "svga" "swrast"
      "iris"
    ];
  }).drivers;
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
          iris
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
        #ultimate.enable = true;
        # localConf = []; ? 
      };
      fonts = with pkgs; [
        corefonts inconsolata awesome
        overpass
        fira-code fira-code-symbols fira-mono
        source-code-pro
        twemoji-color-font
        noto-fonts noto-fonts-extra noto-fonts-emoji
        ttf_bitstream_vera
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
      qemu
      signal-desktop
      #calibre

      rdesktop
      obs-studio
      wlrobs

      qt5.qtwayland
      lxappearance
      adwaita-qt
      breeze-qt5
      pinentry_gnome gnome3.gcr
      networkmanager-openvpn

      libva-utils
      xdg_utils

      #altcoins.dogecoin

      alacritty
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
      gomuks
      lm_sensors
    ];
  };
}
