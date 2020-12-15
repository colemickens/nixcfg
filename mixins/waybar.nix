{ pkgs, config, ... }:

let
  jobpath = "/run/user/1000/srht/jobs";
  jobs = {
    "niche" = "niche";
    "n-w" = "nixpkgs-wayland";
    "f-f-n" = "flake-firefox-nightly";
  };

  suffix = pkgs.lib.mapAttrsToList (k: v: ''
    status="$("${pkgs.jq}/bin/jq" -r '[.results[] | select(.tags=="${v}" and .status!="running" and .status!="cancelled")][0] | .status' "${jobpath}/data")"
    echo "{\"text\":\"''${status}\", \"class\":\"srht-''${status}\"}" > "${jobpath}/${v}-json"
  '') jobs;

  jobsScript = pkgs.writeShellScriptBin "jobs.sh" (pkgs.lib.concatStrings (
    [''
      TOKEN=$(cat ${config.sops.secrets."srht-pat".path})
      BUILD_HOST="https://builds.sr.ht"
      "${pkgs.coreutils}/bin/mkdir" -p "${jobpath}"
      "${pkgs.curl}/bin/curl" \
        -H "Authorization:token ''${TOKEN}" \
        -H "Content-Type: application/json" -X GET \
        "''${BUILD_HOST}/api/jobs" > "${jobpath}/data"
    ''] ++ suffix ));
in
{
  config = {
    sops.secrets."srht-pat" = {
      owner = "cole";
      group = "cole";
    };

    home-manager.users.cole = { pkgs, ... }: {
      systemd.user.services."srht-jobs-status" = {
        Unit.Description = "check srht-jobs status";
        Service = {
          Type = "oneshot";
          ExecStart = "${jobsScript}/bin/jobs.sh";
        };
      };
      systemd.user.timers."srht-jobs-status" = {
        Unit.Description = "check srht jobs status";
        Timer = { OnBootSec = "1m"; OnUnitInactiveSec = "1m"; Unit = "srht-jobs-status.service"; };
        Install.WantedBy = [ "default.target" ];
        # {
        #     wantedBy = [ "timers.target" ];
        #     partOf = [ "srht-${repo}.service" ];
        #     timerConfig.OnCalendar = "hourly";
        # }
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
          modules-right =
            (pkgs.lib.mapAttrsToList (k: v: "custom/srht-${k}") jobs)
            ++ [
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

          modules = (pkgs.lib.mapAttrs' (k: v: 
            pkgs.lib.nameValuePair "custom/srht-${k}" {
              format = "${k}: {}";
              interval = 10;
              exec = "${pkgs.coreutils}/bin/cat ${jobpath}/${v}-json";
              return-type = "json";
            }) jobs) // {
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
