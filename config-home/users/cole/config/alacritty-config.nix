{ ... }:

let
  #font = "Noto Sans Mono";
  font = "Iosevka";
in
{
  enable = true;
  settings = {
    env = {
      TERM = "xterm-256color";
      CURRENT_TERMINAL = "alacritty";
    };
    font = {
      normal.family = "${font}";
      bold.family = "${font}";
      italic.family = "${font}";

      size = 13.0;
    };
    colors = rec {
      primary.foreground = "#babdb6";
      primary.background = "#000000";
      
      normal = {
        black  = "#2e3436";
        red  = "#cc0000";
        green  = "#4e9a06";
        yellow  = "#c4a000";
        blue  = "#3465a4";
        magenta  = "#75507b";
        cyan  = "#06989a";
        white  = "#d3d7cf";
      };
      bright = {
        black  = "#555753";
        red  = "#ef2929";
        green = "#8ae234";
        yellow = "#fce94f";
        blue = "#729fcf";
        magenta = "#ad7fa8";
        cyan = "#34e2e2";
        white = "#eeeeec";
      };
      dim = normal;
    };
  };
}
