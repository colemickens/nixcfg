{ pkgs, config, ... }:

let
  ts = import ./_common/termsettings.nix { inherit pkgs; };
  font = ts.fonts.default;
  colors = ts.colors.default;

  # foot scales the font size?
  fontSize = (builtins.floor (ts.fonts.default.size / 2));

  # maybe we should store the colors without '#' and then add it in alacritty/kitty?
  c = color: builtins.substring 1 10000 color;
in
{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      programs.foot = {
        enable = true;
        settings = {
          main = {
            term = "xterm-256color";
            font = "${font.name}:size=${toString fontSize}";
            notify = "${pkgs.libnotify}/bin/notify-send notify=notify-send -a \${app-id} \${app-id} \${title} \${body}";
            bold-text-in-bright = colors.bold_as_bright;
          };

          colors = rec {
            foreground = c colors.foreground;
            background = c colors.background;

            regular0 = c colors.black;
            regular1 = c colors.red;
            regular2 = c colors.green;
            regular3 = c colors.yellow;
            regular4 = c colors.blue;
            regular5 = c colors.purple;
            regular6 = c colors.cyan;
            regular7 = c colors.white;
          
            bright0 = c colors.brightBlack;
            bright1 = c colors.brightRed;
            bright2 = c colors.brightGreen;
            bright3 = c colors.brightYellow;
            bright4 = c colors.brightBlue;
            bright5 = c colors.brightPurple;
            bright6 = c colors.brightCyan;
            bright7 = c colors.brightWhite;
          };
        };
      };
    };
  };
}
