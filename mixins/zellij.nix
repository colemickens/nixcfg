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
          enableZshIntegration = false; # do NOT auto-start, thank you
          settings = {
            default_mode = "normal";
            default_shell = "nu";
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
