{ pkgs, config, inputs, ... }:

let
  prefs = import ./_preferences.nix { inherit pkgs inputs; };
  colors = prefs.themes.wezterm;

  enable_wayland = "true";
in
{
  config = {
    home-manager.users.cole = { pkgs, ... }@hm: {
      home.packages = with pkgs; [ wezterm ];

      xdg.configFile."wezterm/wezterm.lua".text = ''
        local wezterm = require 'wezterm';

        wezterm.add_to_config_reload_watch_list("${hm.config.xdg.configHome}/wezterm")

        local config = {
          default_prog = { "${prefs.shell.program}" },
          enable_tab_bar = false,
          use_fancy_tab_bar = false,
          front_end = "WebGpu",
          initial_rows = 24,
          initial_cols = 120,
          font_size = ${toString prefs.font.size},
          window_background_opacity = 1.0,
          enable_csi_u_key_encoding = true,
          default_cursor_style = 'BlinkingBar',
          colors = {
            foreground = "${colors.foreground}",
            background = "#000000",
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
          config.enable_wayland = ${enable_wayland}
          config.window_decorations = "RESIZE"
          config.window_close_confirmation = "NeverPrompt"
          -- config.freetype_load_target = "Light"
          -- config.freetype_render_target = "HorizontalLcd"
          local f = wezterm.font_with_fallback({
            {family="${prefs.font.monospace.family}", weight="Regular"},
            {family="Font Awesome", weight="Regular"},
          })
          config.font = f;
        end

        -- issue#3142 workaround START
        local wezterm_action = wezterm.action
        local act = wezterm.action
        config.mouse_bindings = {
          {
            event = { Down = { streak = 1, button = { WheelUp = 1 } } },
            mods = 'NONE',
            action = wezterm_action.ScrollByLine(-1),
          },
          {
            event = { Down = { streak = 1, button = { WheelDown = 1 } } },
            mods = 'NONE',
            action = wezterm_action.ScrollByLine(1),
          },
        }
        -- issue#3142 workaround END
        
        return config
      '';
    };
  };
}
