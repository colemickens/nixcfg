{ config, pkgs, inputs, ... }:

let
  prefs = import ./_preferences.nix { inherit pkgs inputs; };
  convert = color: let c = inputs.nix-rice.lib.${pkgs.stdenv.hostPlatform.system}.color.hexToRgba color; in [ c.r c.g c.b ];
  colors = prefs.themes.zellij;
in
{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      # xdg.configFile."zellij/config.kdl".text = ''
      #   default_shell "nu"
      #   simplified_ui true
      #   pane_frames true
      #   theme "default"
      #   default_layout "compact"
      #   default_mode "normal"
      #   // mouse_mode true # default=true
      #   scroll_buffer_size 99999
      #   scrollback_editor "hx"
      #   ui {
      #     pane_frames {
      #       // rounded_corners true
      #       rounded_corners false
      #     }
      #   }
      # '';
      programs.zellij = {
        enable = true;
        package = inputs.zellij.outputs.packages.${pkgs.stdenv.hostPlatform.system}.default;
        enableZshIntegration = false; # do NOT auto-start, thank you
        settings = {
          default_mode = "normal";
          default_layout = "compact"; # seems to break, I don't think the nix pkg has the default plugins
          default_shell = "nu";
          # simplified_ui = true;
          # pane_frames = true;
          pane_frames = false;
          scrollback_editor = "hx";
          theme = "default";
          # theme = "tokyo-night-light2";
          # themes = {
          #   tokyo-night-light2 = {
          #     fg = [ 52 59 88 ];
          #     bg = [ 213 214 219 ];
          #     black = [ 15 15 20 ];
          #     red = [ 186 75 96 ];
          #     green = [ 72 94 48 ];
          #     yellow = [ 143 94 21 ];
          #     blue = [ 52 84 138 ];
          #     magenta = [ 90 74 120 ];
          #     cyan = [ 15 75 110 ];
          #     white = [ 130 137 172 ];
          #     orange = [ 150 80 39 ];
          #   };
          # };
        };
      };
    };
  };
}
