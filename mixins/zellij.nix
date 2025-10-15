{
  config,
  pkgs,
  inputs,
  ...
}:

{
  config = {
    home-manager.users.cole =
      { pkgs, lib, ... }@hm:
      {
        programs.zellij = {
          enable = true;
          settings = {
            default_mode = "locked";
            default_shell = "nu";
            pane_frames = false;
            scrollback_editor = "hx";
            theme = "tokyo-night-storm";
            session_serialization = false;
          };
          extraConfig = builtins.readFile ./zellij.keybindings.kdl;
        };
      };
  };
}
