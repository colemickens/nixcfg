{ pkgs, config, ... }:

let
  ts = import ./_common/termsettings.nix { inherit pkgs; };
  font = ts.fonts.default;
  colors = ts.colors.default;
in
{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      programs.alacritty = {
        enable = true;
        settings = {
          env = {
            TERM = "xterm-256color";
          };
          font = {
            normal.family = "${font.name}";
            size = font.size;
          };
          draw_bold_text_with_bright_colors = colors.bold_as_bright;
          background_opacity = 0.7;
          colors = rec {
            primary.foreground = colors.foreground;
            primary.background = colors.background;

            normal = {
              black   = colors.black;
              red     = colors.red;
              green   = colors.green;
              yellow  = colors.yellow;
              blue    = colors.blue;
              magenta = colors.purple;
              cyan    = colors.cyan;
              white   = colors.white;
            };
            bright = {
              black   = colors.brightBlack;
              red     = colors.brightRed;
              green   = colors.brightGreen;
              yellow  = colors.brightYellow;
              blue    = colors.brightBlue;
              magenta = colors.brightPurple;
              cyan    = colors.brightCyan;
              white   = colors.brightWhite;
            };
          };
        };
      };
    };
  };
}
