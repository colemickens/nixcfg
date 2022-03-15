{ config, lib, pkgs, inputs, ... }:

let
  prefs = import ./_preferences.nix { inherit inputs config lib pkgs; };
in {
  config = {
    home-manager.users.cole = { pkgs, ... }@hm: {
      gtk = {
        enable = true;
        #preferDark = true;
        font = { name = "Noto Sans 11"; package = pkgs.noto-fonts; };
        iconTheme = { name = "Numix Circle"; package = pkgs.numix-icon-theme; };

        cursorTheme = prefs.cursor;

        theme = { name = "Arc-Dark"; package = pkgs.arc-theme; };
        
        gtk2.configLocation = "${hm.config.xdg.configHome}/gtk-2.0/gtkrc";

        gtk3.extraConfig = {
          gtk-cursor-theme-size = 0;
          gtk-xft-hinting = 1;
          gtk-xft-hintstyle = "slight";
          gtk-xft-antialias = 1; # => font-antialiasing="grayscale"
          gtk-xft-rgba = "rgb"; # => font-rgb-order="rgb"
        };
      };
    };
  };
}
