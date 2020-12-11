{ pkgs, config, ... }:

let
  jobpath = "/run/user/1000/srht/jobs";
  jobs = {
    "n-w"= "nixpkgs-wayland";
    "f-f-n" = "flake-firefox-nightly";
  };

  prefix = ''
    TOKEN=$(cat ${config.sops.secrets."srht-pat".path})
    BUILD_HOST="https://builds.sr.ht"
    "${pkgs.coreutils}/bin/mkdir" -p "${jobpath}"
    "${pkgs.curl}/bin/curl" \
      -H "Authorization:token ''${TOKEN}" \
      -H "Content-Type: application/json" -X GET \
      "''${BUILD_HOST}/api/jobs" > "${jobpath}/data"
  '';

  suffix = pkgs.lib.mapAttrsToList (k: v: ''
    status="$("${pkgs.jq}/bin/jq" -r '[.results[] | select(.tags=="${k}" and .status!="running")][0] | .status' "${jobpath}/data")"
    echo "{\"text\":\"''${status}\", \"class\":\"srht-''${status}\"}" > "${jobpath}/${k}-json"
  '') jobs;

  wholeScript = pkgs.lib.concatStrings ([prefix] ++ suffix);

  jobsScript = pkgs.writeShellScriptBin "jobs.sh" wholeScript;
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
            "idle_inhibitor"
            "tray"
            "pulseaudio"
            "network"
            "cpu"
            "memory"
            "light"
            "clock"
            "battery"
          ] ++ (pkgs.lib.mapAttrsToList (k: v: "custom/srht-${k}") jobs);

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
