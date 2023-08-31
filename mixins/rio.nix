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
              style = "normal";
              weight = 400;
              size = 20;
            };
            # bold = {
            #   family = prefs.font.monospace.family;
            #   style = "normal";
            #   weight = 400;
            # };
          };
        };
      };
    };
  };
}
