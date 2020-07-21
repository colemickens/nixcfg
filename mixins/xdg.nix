{ pkgs, ... }:

{
  config = {
    services.pipewire.enable = true;
    xdg.portal.enable = true;
    xdg.portal.gtkUsePortal = true;
    xdg.portal.extraPortals = with pkgs;
      [ xdg-desktop-portal-wlr xdg-desktop-portal-gtk ];

    home-manager.users.cole = { pkgs, ... }: {
      # TODO: migrate, or duplicate, those to HM
      # services.xdg = { ... }
    };
  };
}
