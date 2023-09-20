{ config, pkgs, inputs, ... }:

let
  prefs = import ./_preferences.nix { inherit pkgs inputs; };
  convert = color: let c = inputs.nix-rice.lib.${pkgs.stdenv.hostPlatform.system}.color.hexToRgba color; in [ c.r c.g c.b ];
  colors = prefs.themes.zellij;

  flakeZellij = inputs.zellij.outputs.packages.${pkgs.stdenv.hostPlatform.system}.default;
  nixpkgsZellij = pkgs.zellij;

  zellijPkg = (if pkgs.stdenv.hostPlatform.system == "x86_64-linux" then flakeZellij else nixpkgsZellij);

  plugin_zjstatus = inputs.zjstatus.outputs.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  config = {
    home-manager.users.cole = { pkgs, lib, ... }@hm: {
      # xdg.configFile."zellij/layouts/custom.kdl".text = hm.lib.hm.generators.toKDL { } {
      #   layout = {
      #     pane = [
      #       {}
      #       {
      #         size = 1;
      #         borderless = true;
      #         plugin = {
      #           location = "file:${plugin_zjstatus}/bin/zjstatus.wasm";
      #         };
      #       }
      #     ];
      #   };
      # };
      xdg.configFile."zellij/layouts/default_zjstatus.kdl".text = ''
        layout {
          pane {}
          pane size=1 borderless=true {
            plugin location="file:${plugin_zjstatus}/bin/zjstatus.wasm" {
              format_left  "{mode} #[fg=#89B4FA,bold]{session} {tabs}"
              format_right "{datetime}"
              format_space ""

              hide_frame_for_single_pane "false"

              mode_normal  "#[bg=#89B4FA] "
              mode_tmux    "#[bg=#ffc387] "

              tab_normal              "#[fg=#6C7086] {index} :: {name} "
              tab_normal_fullscreen   "#[fg=#6C7086] {index} :: {name} [] "
              tab_normal_sync         "#[fg=#6C7086] {index} :: {name} <> "

              tab_active              "#[fg=#9399B2,bold,italic] {name} "
              tab_active_fullscreen   "#[fg=#9399B2,bold,italic] {name} [] "
              tab_active_sync         "#[fg=#9399B2,bold,italic] {name} <> "

              datetime        "#[fg=#6C7086] {format} "
              datetime_format "%Y-%m-%b %H:%M"
              datetime_timezone "Europe/Berlin"
            }
          }
        }
      '';

      programs.zellij = {
        enable = true;
        package = zellijPkg;
        enableZshIntegration = false; # do NOT auto-start, thank you
        settings = {
          default_mode = "normal";
          # default_layout = "compact";
          default_layout = "default_zjstatus";
          default_shell = "nu";
          simplified_ui = true;
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
