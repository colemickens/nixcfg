{ pkgs, ... }:

let
  svc = "nixpkgs-wayland";
  jobpath = "/run/user/1000/srht/jobs";
in
{
  config = {
    sops.secrets."srht-pat" = {
      owner = "cole";
      group = "cole";
    };

    home-manager.users.cole = { pkgs, ... }: {
      systemd.user.services."srht-jobs-status" = {
        description = "check srht-jobs status";
        script = ''
          TOKEN=$(cat ${config.sops.secrets."srht-pat".path})
          BUILD_HOST="https://build.sr.ht"
          "${pkgs.coreutils}/bin/mkdir -p "$(${pkgs.coreutils}/bin/dirname ${jobpath})"
          "${pkgs.curl}/bin/curl" \
            -H "Authorization:token ''${TOKEN}" \
            -H "Content-Type: application/json" -X GET \
            "''${BUILD_HOST}/api/jobs" > ${jobpath}
        '';
      };
      systemd.user.timers."srht-jobs-status" = {
        Unit.Description = "check srht-${svc} status";
        Timer = { OnBootSec = "1m"; OnUnitInactiveSec = "1m"; Unit = "srht-jobs-status.service"; };
        Install.WantedBy = [ "timers.target" ];
      };
      programs.waybar = {
        enable = true;
        style = pkgs.lib.readFile ./waybar.css;
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
            "custom/srht-nixpkgs-wayland"
            "custom/srht-flake-firefox-nightly"
            "idle_inhibitor"
            "tray"
            "pulseaudio"
            "network"
            "cpu"
            "memory"
            "light"
            "clock"
            "battery"
          ];

          modules = {
            "custom/srht-nixpkgs-wayland" = {
              format = "n-w: {}";
              interval = 10;
              exec = "jq -r '[.results[] | select(.tags==\"nixpkgs-wayland\" and .status!=\"running\")][0] | .status' ${jobpath}";
              #return-type = "json";
            };

            "custom/srht-flake-firefox-nightly" = {
              format = "f-f-n: {}";
              interval = 10;
              exec = "jq -r '[.results[] | select(.tags==\"flake-firefox-nightly\" and .status!=\"running\")][0] | .status' ${jobpath}";
              #return-type = "json";
            };

            "sway/workspaces" = {
              all-outputs = true;
              disable-scroll-wraparound = true;
              #enable-bar-scroll = true;
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
            cpu.interval = 2;
            cpu.format = "cpu load({load}%) use({usage}%)";
            memory.format = "mem {}%";
            #backlight.format = "light {percent}%";
            tray.spacing = 10;
            # battery
            clock.format = "{:%a %b %d %H:%M}";
          };
        }];
      };
    };
  };
}
