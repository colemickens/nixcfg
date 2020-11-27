{ config, pkgs, ... }:

let
  ts = import ./_common/termsettings.nix { inherit pkgs; };
  font = ts.fonts.default;
  colors = ts.colors.default;
in 
{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      programs.kitty = {
        enable = true;
        font = {
          package = font.package;
          name = font.name;
        };
        extraConfig = ''
          bold_font ${font.name} Bold
        '';
        settings = {
          font_size = font.size;

          enable_audio_bell = "no";
          visual_bell_duration = "1.0";

          dim_opacity = "0.8";

          foreground = colors.foreground;
          background = colors.background;
          color0  = colors.black;
          color8  = colors.brightBlack;
          color1  = colors.red;
          color9  = colors.brightRed;
          color2  = colors.green;
          color10 = colors.brightGreen;
          color3  = colors.yellow;
          color11 = colors.brightYellow;
          color4  = colors.blue;
          color12 = colors.brightBlue;
          color5  = colors.purple;
          color13 = colors.brightPurple;
          color6  = colors.cyan;
          color14 = colors.brightCyan;
          color7  = colors.white;
          color15 = colors.brightWhite;
        };
      };
    };
  };
}