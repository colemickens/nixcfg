{ config, lib, pkgs, inputs, ... }:
let
  prefs = import ./_preferences.nix { inherit config lib pkgs inputs; };
in
{
  config = {
    fonts = {
      packages = prefs.font.allPackages;

      fontconfig = {
        defaultFonts = {
          serif = [ prefs.font.serif.family ];
          sansSerif = [ prefs.font.sans.family ];
          monospace = [ prefs.font.monospace.family ];
          emoji = [ prefs.font.emoji.family ];
        };
      };
    };
  };
}
