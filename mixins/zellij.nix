{ config, pkgs, inputs, ... }:

let
  prefs = import ./_preferences.nix { inherit pkgs inputs; };
  convert = color: let c = inputs.nix-rice.lib.${pkgs.system}.color.hexToRgba color; in [c.r c.g c.b];
  font = prefs.fonts.default;
  colors = prefs.colors.default;
in
{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      programs.zellij = {
        enable = true;
        settings = {
          default_mode = "normal";
          simplified_ui = true;
          pane_frames = false;
          theme = "default";
          themes = {
            nixdefault = {
              fg = convert colors.foreground;
              bg = convert colors.background;
              gray = convert colors.background;
              black = convert colors.black;
              red = convert colors.red;
              green = convert colors.green;
              yellow = convert colors.yellow;
              blue = convert colors.blue;
              magenta = convert colors.purple;
              cyan = convert colors.cyan;
              white = convert colors.white;
              orange = convert colors.yellow;
            };
          };
        };
      };
    };
  };
}
