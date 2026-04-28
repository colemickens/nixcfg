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
          package = pkgs.callPackage ./zellij-package.nix {};
          settings = {
            default_mode = "locked";
            default_shell = "nu";
            pane_frames = false;
            scrollback_editor = "hx";
            theme = "catppuccin-frappe";
            theme_dark = "catppuccin-frappe";
            theme_light = "catppuccin-latte";
            session_serialization = false;
          };
          extraConfig = builtins.readFile ./zellij.keybindings.kdl;
        };
      };
  };
}
