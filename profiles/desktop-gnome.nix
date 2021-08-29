{ pkgs, lib, config, inputs, ... }:

{
  imports = [
    ./gui.nix
  ];
  config = {
    nixpkgs.config.firefox.enableGnomeExtensions = true;

    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;

    programs.seahorse.enable = false;
    services.gnome.gnome-keyring.enable = lib.mkForce false;

    programs.gnome-documents.enable = false;

    #services.gnome.gnome-disks.enable = true;
    services.gnome.gnome-online-miners.enable = lib.mkForce false;
    services.gnome.gnome-online-accounts.enable = lib.mkForce false;
    services.gnome.tracker.enable = false;
    services.gnome.sushi.enable = false;
    services.gnome.rygel.enable = false;

    services.gnome.core-os-services.enable = true;

    programs.file-roller.enable = true;
    programs.evince.enable = true;

    services.gnome.evolution-data-server.enable = lib.mkForce false;
    programs.geary.enable = false;

    environment.gnome.excludePackages = [
      pkgs.epiphany
    ];

    # TODO: nix2dconf!
    
    home-manager.users.cole = { pkgs, ... }: {
      home.sessionVariables = {
        #MOZ_ENABLE_WAYLAND = "1";

        #SDL_VIDEODRIVER = "wayland";
        #QT_QPA_PLATFORM = "wayland";
        #QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        #_JAVA_AWT_WM_NONREPARENTING = "1";

        #XDG_SESSION_TYPE = "wayland";
      };
      home.packages = with pkgs; [
        pavucontrol
        qjackctl

        gnome3.gnome-tweaks
      ];
    };
  };
}
