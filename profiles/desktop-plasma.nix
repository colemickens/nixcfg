{ pkgs, lib, config, inputs, ... }:

{
  imports = [
    ./gui.nix
  ];
  config = {
    services.xserver.enable = true;
    services.xserver.displayManager.sddm.enable = true;
    services.xserver.desktopManager.plasma5.enable = true;

    nixpkgs.config.firefox.enablePlasmaBrowserIntegration = true;

    environment.systemPackages = with pkgs.plasma5Packages; [
      bismuth
    ];

    # ??
    # xdg.portal.enable = true;
    # xdg.portal.gtkUsePortal = true;
    # xdg.portal.extraPortals = with pkgs;
    #   [ xdg-desktop-portal-wlr xdg-desktop-portal-gtk ];

    home-manager.users.cole = { pkgs, ... }: {
      home.sessionVariables = {

      };
      home.packages = with pkgs; [
        pavucontrol-qt

        kate
        konsole
      ];
    };
  };
}
