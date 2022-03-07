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

        local cs = "_unset"
        cs = "Dimmed Monokia"
        cs = "OneHalfDark"
        cs = "WildCherry"
        cs = "Monokai Remastered"
        cs = "Builtin Solarized Dark"
        cs = "Seti"
        cs = "Dark+"
        cs = "purplepeter"

        local config = {
          use_fancy_tab_bar = false,
          color_scheme = cs,
          initial_rows = 24,
          initial_cols = 120,
          font_size = ${toString font.size},
          enable_tab_bar = false,
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
          
        if wezterm.target_triple == "x86_64-pc-windows-msvc" then
          config.default_prog = { "powershell.exe" }
        else
          config.enable_wayland = true
          config.window_decorations = "TITLE"
          config.window_close_confirmation = "NeverPrompt"
          config.freetype_load_target = "Light"
          config.freetype_render_target = "HorizontalLcd"
          config.font = wezterm.font_with_fallback({
            {family="${font.name}", weight="Medium"},
            {family="Font Awesome", weight="Regular"},
             --"Font Awesome",
          })
        end
        
        return config
      '';
    };
  };
}
