{ config, pkgs, inputs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      xdg.configFile."fireplace/fireplace.yaml".text = (pkgs.lib.generators.toYAML {} {
        logging = {
          style = "Compact";
          color = "Auto";
        };
        
        keys = {
          terminate = { modifiers = [ "Logo" "Shift" ]; key = "Escape"; };
        };
        view = {
          keys = {
            close = { modifiers = [ "Logo" "Shift" ]; key = "Q"; };
          };
        };
        exec = {
          keys = { # default values:
            "$TERMINAL" = { modifiers = ["Logo"]; key = "Return"; };
            "alacritty" = { modifiers = ["Logo" "Shift"]; key = "Return"; };
          };
        };
        workspace = {
          keys = {
            workspace1 = { modifiers = ["Logo"]; key = "1"; };
            workspace2 = { modifiers = ["Logo"]; key = "2"; };
            moveto_workspace1 = { modifiers = ["Logo" "Shift"]; key = "1"; };
            moveto_workspace2 = { modifiers = ["Logo" "Shift"]; key = "2"; };
          };
        };
      });
    };
  };
}
