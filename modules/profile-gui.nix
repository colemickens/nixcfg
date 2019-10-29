{ config, lib, pkgs, ... }:

with lib;

{
  imports = [
    ./mixin-firefox.nix
  ];
  config = {
    environment.variables.MESA_LOADER_DRIVER_OVERRIDE = "iris";
    hardware = {
      brightnessctl.enable = true;
      opengl = {
        enable = true;
        package = (pkgs.mesa.override {
          galliumDrivers = [ "virgl" "svga" "swrast" "iris" ];
          driDrivers = [ "i915" "i965" ];
          vulkanDrivers = [ "intel" ];
        }).drivers;
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
        awesome
        corefonts gelasio ttf_bitstream_vera
        noto-fonts noto-fonts-extra noto-fonts-emoji

        # monospace
        cascadia-code
        inconsolata
        fantasque-sans-mono
        fira-code fira-code-symbols
        fira-mono
        go-font
        monoid
        overpass
        source-code-pro
        sudo-font
        victor-mono
      ];
    };

    environment.systemPackages = with pkgs; [
      # gui apps
      calibre
      evince
      feh
      fractal
      freerdp
      gimp
      google-chrome-dev
      mpv
      pavucontrol
      spectral
      termite
      vscodium

      # utils
      brightnessctl

      # misc
      qt5.qtwayland
      qt5.qtbase

      # appearance
      arc-icon-theme
      arc-theme
      capitaine-cursors
      numix-icon-theme
    ];
  };
}
