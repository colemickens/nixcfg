{ config, lib, pkgs, ... }:

{
  imports = [
    ../../users/cole
    ../common
  ];

  hardware.pulseaudio.enable = true;
  nixpkgs.config.pulseaudio = true;

  services = {
    xserver = {
      autorun = true;
      desktopManager.gnome3 = {
        enable = true;
      };
      displayManager.gdm = {
        enable = true;
        autoLogin = {
          user = "cole";
          enable = true;
        };
      };
      #videoDrivers = [ "intel" ];
      videoDrivers = [ "modesetting" ]; # let individual device profiles override this
      enable = true;
      layout = "us";
      libinput.enable = true;
      useGlamor = true;
    };
  };

  fonts = {
    #enableFontDir = true;
    #enableGhostscriptFonts = true;
    fonts = with pkgs; [
      corefonts inconsolata terminus_font ubuntu_font_family unifont
      fira-code fira-code-symbols fira-mono
      noto-fonts noto-fonts-emoji
      proggyfonts
    ];
  };

  environment.systemPackages = with pkgs; [
    arc-theme numix-icon-theme numix-icon-theme-circle tango-icon-theme
    firefox chromium google-chrome
    freerdpUnstable
    gimp graphviz inkscape
    mplayer vlc
    multibootusb
    pavucontrol
    transmission
    virtmanager virtviewer
    vscode
    yubikey-personalization-gui
    zoom-us
  ];
}

