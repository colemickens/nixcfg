{
  pkgs,
  config,
  inputs,
  ...
}:

let
  rogScript = pkgs.writeShellScript "waybar-rog.sh" ''
    set -euo pipefail
    val="$(${pkgs.asusctl}/bin/asusctl profile -p)"
    if [[ "''${val}" == *"Performance"* ]]; then
      echo $'{"text": "rog prf"}';
    elif [[ "''${val}" == *"Balanced"* ]]; then
      echo $'{"text": "rog bal"}';
    elif [[ "''${val}" == *"Quiet"* ]]; then
      echo $'{"text": "rog qui"}';
    fi
  '';

  btcScript = pkgs.writeShellScript "btc-price.sh" ''
    set -euo pipefail
    usd=$(${pkgs.curl}/bin/curl -L "https://api.coinbase.com/v2/exchange-rates?currency=BTC" \
      | ${pkgs.jq}/bin/jq -r '.data.rates.USD')
    echo "{\"text\": \"''${usd}\"}"
  '';

  pppScript = pkgs.writeShellScript "waybar-ppp.sh" ''
    set -euo pipefail
    val="$(${pkgs.coreutils}/bin/timeout 5 ${pkgs.power-profiles-daemon}/bin/powerprofilesctl get)"
    if [[ "''${val}" == "performance" ]]; then
      echo $'{"text": "ppp prf"}';
    elif [[ "''${val}" == "balanced" ]]; then
      echo $'{"text": "ppp bal"}';
    elif [[ "''${val}" == "power-saver" ]]; then
      echo $'{"text": "ppp pwr"}';
    fi
  '';
  extraModules =
    if config.networking.hostName != "zeph" then
      { }
    else
      {
        "custom/rog" = {
          exec = "${rogScript}";
          return-type = "json";
          interval = 10;
        };
        "custom/ppp" = {
          exec = "${pppScript}";
          return-type = "json";
          interval = 10;
        };
      };
in
# # jobpath = "/run/user/1000/srht/jobs";
# # jobs = {
# #   "niche" = "niche";
# #   "n-w" = "nixpkgs-wayland";
# #   "f-f-n" = "flake-firefox-nightly";
# # };
# # suffix = pkgs.lib.mapAttrsToList (k: v: ''
# #   status="$("${pkgs.jq}/bin/jq" -r '[.results[] | select(.tags=="${v}" and .status!="running" and .status!="cancelled")][0] | .status' "${jobpath}/data")"
# #   echo "{\"text\":\"''${status}\", \"class\":\"srht-''${status}\"}" > "${jobpath}/${v}-json"
# # '') jobs;
# # jobsScript = pkgs.writeShellScriptBin "jobs.sh" (pkgs.lib.concatStrings (
# #   [''
# #     TOKEN=$(cat ${config.sops.secrets."srht-pat".path})
# #     BUILD_HOST="https://builds.sr.ht"
# #     "${pkgs.coreutils}/bin/mkdir" -p "${jobpath}"
# #     "${pkgs.curl}/bin/curl" \
# #       -H "Authorization:token ''${TOKEN}" \
# #       -H "Content-Type: application/json" -X GET \
# #       "''${BUILD_HOST}/api/jobs" > "${jobpath}/data"
# #   ''] ++ suffix ));
# networktoggle = pkgs.writeShellScriptBin "networktoggle.sh" ''
#   if ip link | grep wlan; then
#     sudo ${pkgs.util-linux}/bin/rfkill toggle wlan
#     sudo ${pkgs.systemd}/bin/networkctl reconfigure wlan0
#     ${pkgs.libnotify}/bin/notify-send "toggled wlan0"
#   else
#     ${pkgs.libnotify}/bin/notify-send "no wlan to toggle"
#   fi
# '';
{
  config = {
    # sops.secrets."srht-pat" = {
    #   owner = "cole";
    #   group = "cole";
    # };

    home-manager.users.cole =
      { pkgs, ... }:
      {
        # systemd.user.services."srht-jobs-status" = {
        #   Unit.Description = "check srht-jobs status";
        #   Service = {
        #     Type = "oneshot";
        #     ExecStart = "${jobsScript}/bin/jobs.sh";
        #   };
        # };
        # systemd.user.timers."srht-jobs-status" = {
        #   Unit.Description = "check srht jobs status";
        #   Timer = { OnBootSec = "1m"; OnUnitInactiveSec = "1m"; Unit = "srht-jobs-status.service"; };
        #   Install.WantedBy = [ "default.target" ];
        #   # {
        #   #     wantedBy = [ "timers.target" ];
        #   #     partOf = [ "srht-${repo}.service" ];
        #   #     timerConfig.OnCalendar = "hourly";
        #   # }
        # };
        home.packages = [ pkgs.libappindicator-gtk3 ];
        programs.waybar = {
          enable = true;
          package = inputs.nixpkgs-wayland.outputs.packages.${pkgs.stdenv.hostPlatform.system}.waybar;
          style = pkgs.lib.readFile ./waybar.css;
          systemd.enable = true;
          settings = [
            {
              # ipc = true;
              layer = "top";
              # position = "top";
              modules-left = [
                "sway/mode"
                "sway/workspaces"
              ];
              modules-center = [ "wlr/workspaces" ];
              modules-right =
                [
                  "custom/btc"
                  # "keyboard-state"
                  # "idle_inhibitor"
                  "pulseaudio"
                  "backlight"
                  "tray"
                ]
                ++ (builtins.attrNames extraModules)
                ++ [
                  "cpu"
                  "memory"
                  "network"
                  "temperature"
                  "battery"
                  "clock"
                ];

              modules = (
                {
                  "sway/workspaces" = {
                    all-outputs = true;
                    disable-scroll-wraparound = true;
                    #enable-bar-scroll = true;
                  };
                  "sway/mode" = {
                    tooltip = false;
                  };

                  # # TODO:
                  # keyboard-state = {
                  #   "numlock" = true;
                  #   "capslock" = true;
                  #   "format" = "{name} {icon}";
                  #   "format-icons" = {
                  #     "locked" = "+";
                  #     "unlocked" = "-";
                  #   };
                  # };
                  # TODO: finish this:
                  # "custom/scale" = {
                  #   exec = "${scaleScript}";
                  # };
                  "custom/btc" = {
                    exec = "${btcScript}";
                    return-type = "json";
                    interval = 120;
                  };
                  "wlr/taskbar" = { };
                  temperature = {
                    format = "tmp {temperatureC}";
                  };
                  idle_inhibitor = {
                    format = "iil {icon}";
                    format-icons = {
                      activated = "[x]";
                      deactivated = "[ ]";
                    };
                  };
                  pulseaudio = {
                    format = "vol {volume}";
                    on-click-middle = ''${pkgs.sway}/bin/swaymsg exec "${pkgs.pavucontrol}/bin/pavucontrol"'';
                  };
                  network = {
                    format-wifi = "net {signalStrength}";
                    format-ethernet = "eth";
                  };
                  cpu.interval = 2;
                  cpu.format = "cpu {usage}";
                  memory.format = "mem {}";
                  backlight = {
                    format = "nit {percent}";
                    on-scroll-up = "${pkgs.brightnessctl}/bin/brightnessctl set 2%+";
                    on-scroll-down = "${pkgs.brightnessctl}/bin/brightnessctl set 2%-";
                  };
                  tray.spacing = 10;
                  # battery
                  clock = {
                    format = "{:%b-%d %H:%M}";
                  };
                  battery = {
                    format = "bat {}";
                    states = {
                      warning = 25;
                      critical = 15;
                    };
                  };
                }
                // extraModules
              );
            }
          ];
        };
      };
  };
}
