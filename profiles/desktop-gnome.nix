{ pkgs, lib, config, inputs, ... }:

{
  imports = [
    ./gui.nix

    # ugh, just breaks chrome anyway:
    # ../mixins/wayland-tweaks.nix
  ];
  config = {
    nixpkgs.config.firefox.enableGnomeExtensions = true;

    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;

    programs.seahorse.enable = false;
    services.gnome.gnome-keyring.enable = lib.mkForce false;

    programs.gnome-documents.enable = false;

    xdg.portal.enable = true;
    xdg.portal.gtkUsePortal = true;
    # xdg.portal.extraPortals = with pkgs;
    #   [ xdg-desktop-portal-wlr /*xdg-desktop-portal-gtk*/ ];

    #services.gnome.gnome-disks.enable = true;
    services.gnome.gnome-online-miners.enable = lib.mkForce false;
    services.gnome.gnome-online-accounts.enable = lib.mkForce false;
    services.gnome.tracker.enable = false;
    services.gnome.sushi.enable = false;
    services.gnome.rygel.enable = false;

    services.gnome.core-os-services.enable = true;

    programs.file-roller.enable = true;
    programs.evince.enable = true;

    services.gnome.gnome-initial-setup.enable = false;
    services.gnome.tracker-miners.enable = false;

    services.gnome.evolution-data-server.enable = lib.mkForce false;
    programs.geary.enable = false;

    #  - You have set services.power-profiles-daemon.enable = true;
    #    which conflicts with services.tlp.enable = true;
    services.tlp.enable = lib.mkForce false;

    environment.gnome.excludePackages = [
      pkgs.yelp
      pkgs.gnome.gnome-maps
      pkgs.gnome.gnome-initial-setup
      pkgs.gnome.gnome-contacts
      pkgs.gnome-photos
      pkgs.gnome.gnome-calendar
      pkgs.gnome.gnome-control-center
      # also unneeded:
      # weather calculator text-editor document-scanner connections
      # videos cheese music tour
    ];

    # TODO: nix2dconf!
    
    home-manager.users.cole = { pkgs, ... }: {
      home.sessionVariables = {
        MOZ_ENABLE_WAYLAND = "1";

        SDL_VIDEODRIVER = "wayland";
        QT_QPA_PLATFORM = "wayland";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        _JAVA_AWT_WM_NONREPARENTING = "1";

        TERMINAL = "gnome-terminal";
      };
      home.packages = with pkgs; [
        pavucontrol
        qjackctl

        gnome3.gnome-tweaks
      ];
    };
  };
}
