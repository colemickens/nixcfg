{ config, pkgs, inputs, ... }:

let
  prefs = import ./_preferences.nix { inherit pkgs inputs; };
  convert = color: let c = inputs.nix-rice.lib.${pkgs.stdenv.hostPlatform.system}.color.hexToRgba color; in [ c.r c.g c.b ];
  colors = prefs.themes.zellij;

  flakeZellij = inputs.zellij.outputs.packages.${pkgs.stdenv.hostPlatform.system}.default;
  nixpkgsZellij = pkgs.zellij;
  
  zellijPkg = (if pkgs.stdenv.hostPlatform.system == "x86_64-linux" then flakeZellij else nixpkgsZellij);
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
        package = zellijPkg;
        enableZshIntegration = false; # do NOT auto-start, thank you
        settings = {
          default_mode = "normal";
          default_layout = "compact"; # seems to break, I don't think the nix pkg has the default plugins
          default_shell = "nu";
          # simplified_ui = true;
          pane_frames = true;
          scrollback_editor = "hx";
          # theme = "default";
          theme = "tokyo-night-storm";
          # theme = "catppuccin-mocha"; # todo; try
          # theme = "nord"; # not enough pane-frame contrast
        };
      };
    };
  };
}
