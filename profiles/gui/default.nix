{ config, lib, pkgs, ... }:

with lib;

let
  spkgs = (import /etc/nixpkgs-sway/default.nix {
    config = config.nixpkgs.config;
  }).pkgs;
  fpkgs = (import <nixpkgs> {
    config.allowUnfree = true;
    overlays = [(import /etc/nixos/nixpkgs-mozilla/firefox-overlay.nix)];
  }).latest;
in
{
  imports = [
    ../../users/cole
    ../common
  ];

  config = { 
    environment.variables.MOZ_USE_XINPUT2 = "1";
    hardware.pulseaudio.enable = true;
    nixpkgs.config.pulseaudio = true;

    programs = {
      light.enable = true;
      sway = {
        enable = true;
        package = spkgs.sway;
      };
    };

    services = {
      flatpak.enable = true;
    };

    fonts = {
      #enableFontDir = true;
      #enableGhostscriptFonts = true;
      fonts = with pkgs; [
        corefonts inconsolata awesome
        fira-code fira-code-symbols fira-mono
        source-code-pro
        noto-fonts noto-fonts-emoji
      ];
    };

    environment.systemPackages = with pkgs; [
      # firefox-nightly-bin from the mozilla-nixpkgs overlay
      fpkgs.firefox-nightly-bin
      # apperance
      arc-theme numix-icon-theme numix-icon-theme-circle tango-icon-theme
      # browsers
      chromium google-chrome
      # misc desktop
      freerdpUnstable
      # images
      gimp graphviz inkscape # TODO: add basic image viewer? todo: whats a good one?
      # video
      vlc mpv
      # audio
      pavucontrol # TODO: phase out in favor of pulsemixer
      # misc internet
      spotify transmission
      # virtualization # only if libvirtd is enabled though.... (which it isn't anywhere right now)
      # virtmanager virtviewer
      # editors
      vscode kate gnome3.gedit
      # communication
      slack signal-desktop zoom-us

      # TODO: put these behind an option
      # KDE
      ark
      # GNOME
      gnome3.gnome-tweaks # TODO: enabled to cfg gtk w/ sway :( TODO: figure better solution

      # tiling wm specific
      i3status-rust
      termite
      spkgs.redshift-wayland
      dmenu
      xwayland
      epiphany # TODO: remove when firefox/wayland works well
      pulsemixer
    ];
  };
}

