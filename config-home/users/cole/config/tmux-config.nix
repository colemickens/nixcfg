{ pkgs, ... }:

{
  enable = true;
  escapeTime = 0;
  keyMode = "vi";
  mouseBindings = true; # TODO
  newSession = true;
  sensibleOnTop = true;
  extraConfig = ''
    set -g mouse on
  '';
}

