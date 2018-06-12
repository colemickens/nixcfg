{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.guiOptions;
in
{
  options = {
    guiOptions.desktopEnvironment = mkOption { type = types.string; default = "gnome"; };
  };

  imports = [
    ../../users/cole
    ../common
  ];

#  config = mkIf (cfg.desktopEnvironment == "kde") {
#    services.xserver.desktopManager.plasma5.enable = true;
#  } // mkIf (cfg.desktopEnvironment == "gnome") {
#    services.xserver.displayManager.gdm.enable = true;
#    services.xserver.displayManager.gdm.autoLogin = { user = "cole"; enable = true; };
#    services.xserver.desktopManager.gnome3.enable = true;
#  } //
  config = { 
    hardware.pulseaudio.enable = true;
    nixpkgs.config.pulseaudio = true;

    services = {
      xserver = {
        displayManager.gdm.enable = true;
        displayManager.gdm.autoLogin = { user = "cole"; enable = true; };
        desktopManager.gnome3.enable = true;
        autorun = true;
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
      gparted
      pavucontrol
      spotify
      transmission
      virtmanager virtviewer
      vscode
      yubikey-personalization-gui
      zoom-us
    ];
  };
}

