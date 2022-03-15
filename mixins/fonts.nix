{ config, lib, pkgs, inputs, ... }:
let
  prefs = import ./_preferences.nix { inherit config lib pkgs inputs; };
in
{
  config = {
    fonts = {
      fonts = prefs.font.allPackages;

      fontconfig = {
        defaultFonts = {
          monospace = [ prefs.font.default.family ];
          emoji = [ prefs.font.emoji.family ];
        };
      };
    };
  };
}
