{ pkgs, ... }:

{
  enable = true;
  style = pkgs.lib.readFile ./waybar-config.css;
  #systemd = {
  #  enable = true;
  #  withSwayIntegration = true;
  #};
  settings = [{
    layer = "top";
    position = "top";
    modules-left = [
      "sway/mode"
      "sway/workspaces"
    ];
    modules-center = [];
    modules-right = [
      "idle_inhibitor"
      "pulseaudio"
      "network"
      "cpu"
      "memory"
      "backlight"
      "tray"
      "battery"
      "clock"
    ];

    modules = {
      "sway/workspaces" = {
        all-outputs = true;
        disable-scroll-wraparound = true;
        enable-bar-scroll = true;
      };
      "sway/mode" = { tooltip = false; };

      #"idle_inhibitor" = { format = "{icon}"; };
      pulseaudio = {
        format = "{desc}:{volume}%";
        on-click-middle = "${pkgs.sway}/bin/swaymsg exec \"${pkgs.alacritty}/bin/alacritty -e pulsemixer\"";
      };
      network = {
        format-wifi = "{ifname} ssid({essid} {signalStrength}%) up({bandwidthUpBits}) down({bandwidthDownBits})";
        format-ethernet = "{ifname} up({bandwidthUpBits}) down({bandwidthDownBits})";
      };
      cpu.format = "cpu load({load}%) use({usage}%)";
      memory.format = "mem {}%";
      backlight.format = "light {percent}%";
      tray.spacing = 10;
      # battery
      clock.format = "{:%a %b %d %H:%M}";
    };
  }];
}
