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
          font = prefs.font.monospace.family;
          font-size = 20;
        };
      };
    };
  };
}
