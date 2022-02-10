{ pkgs, config, ... }:

let
  ts = import ./_common/termsettings.nix { inherit pkgs; };
  font = ts.fonts.default;
  colors = ts.colors.default;

  # foot scales the font size?
  #fontSize = (builtins.ceil (ts.fonts.default.size / 1.25) - 1);
  fontSize = ts.fonts.default.size;
in
{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      home.packages = with pkgs; [ wezterm ];

      # wezterm.enable = true;
      # wezterm.config = TODO;

      xdg.configFile."wezterm/wezterm.lua".text = ''
        local wezterm = require 'wezterm';

        local config = {
          enable_wayland = true,
          font = wezterm.font_with_fallback({
            {family="${font.name}", weight="Regular"},
            {family="Font Awesome", weight="Regular"},
            --"Font Awesome",
          }),
          freetype_load_target = "Light",
          freetype_render_target = "HorizontalLcd",
          -- default_prog = {"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe"},
          initial_rows = 24,
          initial_cols = 120,
          font_size = ${toString font.size},
          colors = {
            foreground = "${colors.foreground}",
            background = "${colors.background}",

            ansi = {
              "${colors.black}",
              "${colors.red}",
              "${colors.green}",
              "${colors.yellow}",
              "${colors.blue}",
              "${colors.purple}",
              "${colors.cyan}",
              "${colors.white}"
            },
            brights = {
              "${colors.brightBlack}",
              "${colors.brightRed}",
              "${colors.brightGreen}",
              "${colors.brightYellow}",
              "${colors.brightBlue}",
              "${colors.brightPurple}",
              "${colors.brightCyan}",
              "${colors.brightWhite}"
            },
          }
        }

        return config
      '';
    };
  };
}
