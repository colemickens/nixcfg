{ pkgs, ... }:

let
  ts = import ./_common/termsettings.nix { inherit pkgs; };
  font = ts.fonts.default;
  colors = ts.colors.default;
in 

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      programs.termite = {
        enable = false;
        font = "${font.name} ${toString font.size}";
        cursorColor = colors.cursorColor;
        foregroundColor = colors.foreground;
        foregroundBoldColor = colors.foregroundBold;
        backgroundColor = colors.background;
        clickableUrl = true;
        colorsExtra = ''
          color0  = ${colors.black}
          color8  = ${colors.brightBlack}
          color1  = ${colors.red}
          color9  = ${colors.brightRed}
          color2  = ${colors.green}
          color10 = ${colors.brightGreen}
          color3  = ${colors.yellow}
          color11 = ${colors.brightYellow}
          color4  = ${colors.blue}
          color12 = ${colors.brightBlue}
          color5  = ${colors.purple}
          color13 = ${colors.brightPurple}
          color6  = ${colors.cyan}
          color14 = ${colors.brightCyan}
          color7  = ${colors.white}
          color15 = ${colors.brightWhite}
        '';
      };
    };
  };
}
