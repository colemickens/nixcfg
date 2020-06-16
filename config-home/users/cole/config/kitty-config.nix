{ pkgs }:

{
  enable = true;
  font = {
    package = pkgs.iosevka;
    name = "Iosevka";
  };
  settings = {
    font_size = 13;

    foreground = "#babdb6";
    background = "#000000";

    env = "CURRENT_TERMINAL=kitty";

    color0  = "#2e3436";
    color8  = "#555753";
    color1  = "#cc0000";
    color9  = "#ef2929";
    color2  = "#4e9a06";
    color10 = "#8ae234";
    color3  = "#c4a000";
    color11 = "#fce94f";
    color4  = "#3465a4";
    color12 = "#729fcf";
    color5  = "#75507b";
    color13 = "#ad7fa8";
    color6  = "#06989a";
    color14 = "#34e2e2";
    color7  = "#d3d7cf";
    color15 = "#eeeeec";
  };
}
