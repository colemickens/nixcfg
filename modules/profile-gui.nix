{ config, lib, pkgs, ... }:

with lib;

{
  imports = [
    ./mixin-firefox.nix
    #./mixin-chromium.nix
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

    #gtk = {
    #  enable = true;
    #  font = { name = "Noto Sans 11"; package = pkgs.noto-fonts; };
    #  iconTheme = { name = "Numix"; package = pkgs.numix-icon-theme; };
    #  cursorTheme = { name = "Adwaita"; package = pkgs.gnome3.adwaita-icon-theme; };
    #  theme = { name = "Arc-Dark"; package = pkgs.arc-theme; };
    #};
    #qt = {
    #  font = { name = "Noto Sans,10,-1,5,50,0,0,0,0,0,Regular"; package = pkgs.noto-fonts; };
    #  iconTheme = { name = "Numix"; package = pkgs.numix-icon-theme; };
    #  style = { name = "Breeze"; package = pkgs.breeze-qt5; };
    #};

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
      evince
      fractal
      #freerdp
      wlfreerdp
      gimp
      google-chrome-dev
      kitty
      mpv
      gnome3.nautilus
      pavucontrol
      qemu
      spectral
      termite
      thunderbird
      vscodium

      hicolor-icon-theme

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

      # 
      tor-browser-bundle-bin

      # ewww. all shit and propreitary and electrony and javay and yuck
      discord
      minecraft
      riot-desktop
      slack
      spotify
      ripcord
    ];
  };
}
