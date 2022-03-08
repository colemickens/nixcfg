{ config, pkgs, inputs, ... }:

let
  ts = import ./_common/termsettings.nix { inherit pkgs inputs; };
  convert = ts.termlib.convertToDecArray;
  font = ts.fonts.default;
  colors = ts.colors.default;
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
