{ pkgs, config, inputs, ... }:

let
  prefs = import ./_preferences.nix { inherit pkgs inputs; };
  font = prefs.font;
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
              family = prefs.font.monospace.family;
              style = "Regular";
              weight = 400;
            };
            bold = {
              family = prefs.font.monospace.family;
              style = "Bold";
              weight = 600;
            };
            italic = {
              family = prefs.font.monospace.family;
              style = "Italic";
              weight = 400;
            };
          };
        };
      };
    };
  };
}
