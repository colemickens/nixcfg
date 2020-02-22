{ config, lib, pkgs, ... }:

with lib;

{
  imports = [
    ./mixin-firefox.nix
    ./mixin-chromium.nix
  ];
  config = {
    hardware = {
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

    services.avahi = {
      enable = true;
      #nssmdns = true;
      publish.domain = true;
      publish.enable = true;
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
      alacritty
      calibre
      #(chromium-git_80.overrideAttrs(old: {
      #  customGnFlags = {
      #    use_vaapi = true;
      #    use_ozone = true;
      #    #use_system_minigbm = true;
      #    ozone_auto_platforms = false;
      #    ozone_platform = "wayland";
      #    ozone_platform_wayland = true;
      #    ozone_platform_x11 = true;
      #    ozone_platform_headless = true;
      #  };
      #}))
      evince
      fractal
      freerdp
      gimp
      #google-chrome-dev
      kitty
      mpv
      gnome3.nautilus
      pavucontrol
      qemu
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

      discord
      tor-browser-bundle-bin
      minecraft
      riot-desktop
      slack
    ];
  };
}
