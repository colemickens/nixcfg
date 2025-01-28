{
  pkgs,
  config,
  inputs,
  ...
}:

let
  prefs = import ./_preferences.nix { inherit pkgs inputs; };
  font = prefs.font;
  colors = prefs.themes.alacritty;

in
{
  config = {
    home-manager.users.cole =
      { pkgs, ... }:
      {
        programs.ghostty = {
          enable = true;
          settings = {
            theme = "dark:\"Builtin Tango Dark\",light:\"Builtin Tango Light\"";
            font-family = "${font.monospace.family}";
            window-decoration = false;
            gtk-titlebar = false;
            background-opacity = "0.9";
          };
        };
      };
  };
}
