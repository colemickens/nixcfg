{ inputs, lib, ... }:

let
  macSettings = {
    app-notifications = false;
    font-family = "Iosevka Fixed";
    font-style = "Medium";
    font-size = 14;
    adjust-cell-width = "-5%";
    background-opacity = ".8";
    background-blur-radius = 40;
    term = "xterm-256color";
    theme = "dark:Catppuccin Frappe,light:Catppuccin Latte";
    auto-update-channel = "tip";
  };
  linuxSettings = {
    app-notifications = false;
    font-family = "Iosevka Fixed";
    font-style = "Medium";
    font-size = 11;
    adjust-cell-width = "-5%";
    term = "xterm-256color";
    window-decoration = false;

    background-opacity = ".8";
    background-blur-radius = 40;
    theme = "dark:Catppuccin Frappe,light:Catppuccin Latte";
  };
in
{
  config = {
    home-manager.users.cole =
      { pkgs, ... }:
      {
        programs = {
          ghostty = {
            enable = true;
            package = (if pkgs.stdenv.hostPlatform.system == "aarch64-darwin" then null else inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default);
            settings = (if pkgs.stdenv.hostPlatform.system == "aarch64-darwin" then macSettings else linuxSettings);
          };
        };
      };
  };
}
