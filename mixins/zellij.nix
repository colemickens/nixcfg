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
            theme = "catppuccin-frappe";
            theme_dark = "catppuccin-frappe";
            theme_light = "catppuccin-latte";
            session_serialization = false;
            show_startup_tips = false; # I never read them and I swear theres a bug that hangs my term tab
          };
          extraConfig = builtins.readFile ./zellij.keybindings.kdl;
        };
      };
  };
}
