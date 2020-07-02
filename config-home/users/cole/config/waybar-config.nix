{ pkgs, ... }:

{
  enable = true;
  style = pkgs.lib.readFile ./waybar-config.css;
  systemd = {
    enable = true;
    withSwayIntegration = true;
  };
  settings = [{
    layer = "top";
    position = "top";
    height = 30;
    output = [ "DP-1" ];
    modules-left = [ "sway/workspaces" "sway/mode" ];
    modules-center = [ "sway/window" ];
    modules-right = [
      "idle_inhibitor"
      "pulseaudio"
      "network"
      "cpu"
      "memory"
      "backlight"
      "tray"
      # "battery" # not in default modules, throws warning, but hen again so does smth else
      "clock"
    ];
    
    # modules = {
    #   "sway/workspaces" = {
    #     disable-scroll = true;
    #     all-outputs = true;
    #   };
    #   "sway/mode" = { tooltip = false; };
    #   "sway/window" = { max-length = 120; };
    #   "idle_inhibitor" = { format = "{icon}"; };
    # };
  }];
}
