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
    };
    font = {
      normal.family = "${font}";
      bold.family = "${font}";
      italic.family = "${font}";

      size = 14.0;
    };
  };
}
