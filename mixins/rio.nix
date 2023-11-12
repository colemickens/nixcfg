{ pkgs, config, inputs, ... }:

let
  prefs = import ./_preferences.nix { inherit pkgs inputs; };
  font = prefs.font.monospace.family;
  colors = prefs.themes.alacritty;
in
{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      programs.rio = {
        enable = true;
        settings = {
          fonts = {
            size = 20;
            regular = {
              family = font;
              style = "Regular";
              weight = 400;
            };
            bold = {
              family = font;
              style = "Bold";
              weight = 600;
            };
            italic = {
              family = font;
              style = "Italic";
              weight = 400;
            };
          };
        };
      };
    };
  };
}
