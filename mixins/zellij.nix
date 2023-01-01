{ config, pkgs, inputs, ... }:

let
  prefs = import ./_preferences.nix { inherit pkgs inputs; };
  convert = color: let c = inputs.nix-rice.lib.${pkgs.hostPlatform.system}.color.hexToRgba color; in [ c.r c.g c.b ];
  colors = prefs.themes.zellij;
in
{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      programs.zellij = {
        enable = true;
        settings = {
          default_mode = "normal";
          ui.pane_frames.rounded_corners = true;
          default_layout = "compact";
          default_shell = "nu";
          simplified_ui = true;
          pane_frames = true;
          scrollback_editor = "hx";
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
