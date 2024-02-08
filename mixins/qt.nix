{ config, pkgs, ... }:

{
  config = {
    home-manager.users.cole =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          breeze-gtk
          breeze-qt5
          breeze-icons
        ];
        qt = {
          enable = true;
          # platformTheme = "gtk";
          # platformTheme = "gnome";
          # style = {
          #   name = "adwaita-dark";
          #   package = pkgs.adwaita-qt;
          # };
        };
      };
  };
}
