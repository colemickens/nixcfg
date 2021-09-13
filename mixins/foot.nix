{ pkgs, config, ... }:

let
  ts = import ./_common/termsettings.nix { inherit pkgs; };
  font = ts.fonts.default;
  colors = ts.colors.default;
  # TODO: bold/bright setting
  bold_bright = true;
in
{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      programs.foot = {
        enable = true;
        settings = {
          main = {
            term = "xterm-256color";
            font = "${font.name}:size=${toString font.size}";
            notify = "${pkgs.libnotify}/bin/notify-send notify=notify-send -a \${app-id} \${app-id} \${title} \${body}";
            bold-text-in-bright = bold_bright;
          };
          
          colors = rec {
            foreground = colors.foreground;
            background = colors.background;

            regular0   = colors.black;
            regular1     = colors.red;
            regular2   = colors.green;
            regular3  = colors.yellow;
            regular4    = colors.blue;
            regular5 = colors.purple;
            regular6    = colors.cyan;
            regular7   = colors.white;
          
            bright0 = colors.brightBlack;
            bright1 = colors.brightRed;
            bright2 = colors.brightGreen;
            bright3 = colors.brightYellow;
            bright4 = colors.brightBlue;
            bright5 = colors.brightPurple;
            bright6 = colors.brightCyan;
            bright7 = colors.brightWhite;
          };
        };
      };
    };
  };
}
