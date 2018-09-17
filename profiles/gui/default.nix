{ config, lib, pkgs, ... }:

with lib;

let
in
{
  imports = [
    ../../users/cole
    ../common
  ];

  config = { 
    hardware.pulseaudio.enable = true;
    nixpkgs.config.pulseaudio = true;

    services = {
      xserver = {
        displayManager.sddm.enable = true;
        desktopManager.plasma5.enable = true;
        autorun = true;
        videoDrivers = [ "intel" ];
        #videoDrivers = [ "modesetting" ]; # let individual device profiles override this
        deviceSection = ''
          Option "TearFree" "true"
        '';
        enable = true;
        layout = "us";
        libinput = {
          enable = true;
          clickMethod = "clickfinger";
        };
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
      # firefox-nightly-bin from the mozilla-nixpkgs overlay
      (import <nixpkgs> {
        config.allowUnfree = true;
        overlays = [(import /etc/nixos/nixpkgs-mozilla/firefox-overlay.nix)];
      }).latest.firefox-nightly-bin

      arc-theme numix-icon-theme numix-icon-theme-circle tango-icon-theme
      chromium google-chrome
      freerdpUnstable
      kate
      gimp graphviz inkscape
      mplayer vlc
      multibootusb
      gparted
      pavucontrol
      pulseaudio-dlna
      spotify
      transmission
      virtmanager virtviewer
      vscode
      yubikey-personalization-gui
      zoom-us

      redshift-plasma-applet
      redshift

      slack
      ark
      keybase-gui
      kbfs
      signal-desktop
    ];
  };
}

