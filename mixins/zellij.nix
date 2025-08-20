{
  config,
  pkgs,
  inputs,
  ...
}:

let
  prefs = import ./_preferences.nix { inherit pkgs inputs; };

  hostColor = config.nixcfg.common.hostColor;

  crossBuild = (pkgs.stdenv.hostPlatform.system != pkgs.stdenv.buildPlatform.system);

  # zellijFlake = inputs.zellij-nix.outputs.packages.${pkgs.stdenv.hostPlatform.system}.default;
  # zellijNixpkgs = pkgs.zellij;
  # zellijPkg = (if !crossBuild then zellijFlake else zellijNixpkgs);
  zellijPkg = pkgs.zellij;

  _defaultShell = prefs.default_shell;

  plugin_zjstatus = inputs.zjstatus.outputs.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  config = {
    home-manager.users.cole =
      { pkgs, lib, ... }@hm:
      {
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

        # TODO:
        # - not sure what format_space does?
        xdg.configFile."zellij/layouts/default_zjstatus.kdl" = lib.mkIf (!crossBuild) {
          text = ''
            layout {
              pane {}
              pane size=2 borderless=true {
                plugin location="file:${plugin_zjstatus}/bin/zjstatus.wasm" {
                  format_left  "{mode} #[fg=${hostColor},bold]{session} {tabs}"
                  format_right ""
                  format_space "|"

                  hide_frame_for_single_pane "false"

                  mode_normal  "#[bg=${hostColor},fg=#000000] "
                  mode_tmux    "#[bg=${hostColor},fg=#000000] tmux "
                  mode_locked  "#[bg=${hostColor},fg=#000000] locked "

                  border_enabled   "true"
                  border_char      "─"
                  border_format    "#[fg=${hostColor}]"
                  border_position  "top"

                  tab_normal              "#[fg=#6C7086] {name} "
                  tab_normal_fullscreen   "#[fg=#6C7086] {name} [] "
                  tab_normal_sync         "#[fg=#6C7086] {name} <> "

                  tab_active              "#[bg=#6C7086,fg=#000000,bold] {name} "
                  tab_active_fullscreen   "#[bg=#6C7086,fg=#000000] {name} [] "
                  tab_active_sync         "#[bg=#6C7086,fg=#000000,bold] {name} <> "
                }
              }
            }
          '';
        };

        programs.zellij = {
          enable = true;
          package = zellijPkg;
          enableZshIntegration = false; # do NOT auto-start, thank you
          settings = {
            default_mode = "normal";
            default_layout = "default_zjstatus"; # previously "compact"
            default_shell = _defaultShell;
            simplified_ui = true;
            pane_frames = false;
            scrollback_editor = "hx";
            theme = "tokyo-night-storm";
            session_serialization = false;
          };
        };
      };
  };
}
