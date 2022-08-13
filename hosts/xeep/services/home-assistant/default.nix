{ pkgs, ... }:

# TODO: share trusted networks with nginx

let
  secrets = import ./secrets.nix;
  trusted_networks = [
    "192.168.0.0/16" # default chimera network
    #"172.27.66.0/24" # wireguard network
    "100.64.0.0/10" # tailscale network
    "fd7a:115c:a1e0:ab12:0000:0000:0000:0000/64"
    #"192.168.69.0/24" # esphome network (but doesn't need to hit HA frontdoor)
  ];

  ha_host = "0.0.0.0";
  ha_port = 8123;
  ha_host_port = "${ha_host}:${toString ha_port}";

  nanoleaf_light = "light.nanoleaf_light_panels_5b_38_ef";
  cleo_lamp_switch = "switch.wp6_sw102_relay";
  candle_switches = [
    "switch.wp6_sw105_relay" # den-bathroom
    "switch.wp6_sw107_relay" # candle1
    "switch.wp6_sw108_relay" # candle2
    "switch.wp6_sw109_relay" # candle3
  ];
in
{
  config = {
    networking.firewall = { allowedTCPPorts = [ ha_port ]; };

    # services.prometheus = {
    #   enable = true;
    #   scrapeConfigs = [{
    #     job_name = "home-assistant-scrape";
    #     scrape_interval = "30s";
    #     metrics_path = "/api/prometheus";
    #     bearer_token = secrets.ha_access_token_prometheus;
    #     scheme = "http";
    #     static_configs = [{ targets = [ ha_host_port ]; }];
    #   }];
    #   exporters = {
    #     node = {
    #       enable = true;
    #       enabledCollectors = [ "systemd" ];
    #     };
    #     tor = { enable = true; };
    #     #unifi =  {
    #     #  enable = true;
    #     #  unifiInsecure = true;
    #     #  unifiAddress = "https://127.0.0.1:8443";
    #     #  unifiUsername = "admin";
    #     #  unifiPassword = "foo";
    #     #};
    #   };
    # };
    # services.grafana = {
    #   enable = true;
    #   domain = "grafana.cleothecat.duckdns.org";
    #   auth.anonymous.enable = true;
    #   provision = {
    #     enable = true;
    #     #dashboards = {
    #     #};
    #     datasources = [{
    #       name = "prometheus";
    #       url = "http://localhost:9090";
    #       type = "prometheus";
    #       access = "proxy";
    #     }];
    #   };
    # };

    services.home-assistant = {
      enable = true;
      config = {
        homeassistant = {
          name = "Chimera HomeAss";
          time_zone = "US/Pacific";
          latitude = 47.6;
          longitude = -122.3;
          elevation = 60;
          unit_system = "metric";
          temperature_unit = "C";
          auth_providers = [
            # must be enabled to finish bootstrap/onboard:
            #{ type = "homeassistant"; }
            {
              type = "trusted_networks";
              trusted_networks = [ "127.0.0.1" ] ++ trusted_networks;
              allow_bypass_login = true;
            }
          ];
        };

        automation = [
          # {
          #   id = "bedtime";
          #   alias = "Bed Time";
          #   mode = "single";
          #   action = [
          #     {
          #       service = "switch.turn_on";
          #       target.entity_id = nanoleaf;
          #     }
          #  --- after a delay, turn off nanoleaf and dabrig?
          #   ];
          # }
          {
            id = "nanoleaf_on";
            alias = "Nanoleaf (on) (8:30)";
            mode = "single";
            trigger = {
              platform = "time_pattern";
              hours = "8";
              minutes = "/30";
            };
            action = [{
              service = "light.turn_on";
              target.entity_id = nanoleaf_light;
            }];
          }
          {
            id = "nanoleaf_bed";
            alias = "Nanoleaf (bed) (21:00)";
            mode = "single";
            trigger = {
              platform = "time_pattern";
              hours = "21";
            };
            action = [{
              service = "light.turn_on";
              target.entity_id = nanoleaf_light;
            }];
          }
          # TODO: some way to make it slowly draw down over the 9-10pm hours?
          {
            id = "nanoleaf_off";
            alias = "Nanoleaf (off) (22:00)";
            mode = "single";
            trigger = {
              platform = "time_pattern";
              hours = "22";
            };
            action = [{
              service = "light.turn_off";
              target.entity_id = nanoleaf_light;
            }];
          }
          {
            id = "cleo_lamp_on";
            alias = "Cleo Lamp (on) (20:30)";
            mode = "single";
            trigger = {
              platform = "time_pattern";
              hours = "20";
              minutes = "/30";
            };
            action = [{
              service = "switch.turn_on";
              target.entity_id = cleo_lamp_switch;
            }];
          }
          {
            id = "cleo_lamp_off";
            alias = "Cleo Lamp (off) (8:30)";
            mode = "single";
            trigger = {
              platform = "time_pattern";
              hours = "8";
              minutes = "/30";
            };
            action = [{
              service = "switch.turn_off";
              target.entity_id = cleo_lamp_switch;
            }];
          }
          {
            id = "candle_warmers_schedule_on";
            alias = "Candles (on)";
            mode = "single";
            trigger = {
              platform = "time_pattern";
              hours = "/3";
              minutes = "0";
            };
            action = [{
              service = "switch.turn_on";
              target.entity_id = candle_switches;
            }];
          }
          {
            id = "candle_warmers_schedule_off";
            alias = "Candles (off)";
            mode = "single";
            # we're going to fire every hour, at 30 mins after the top
            # but only run in the hours that come after the /3 hours...
            condition = [
              {
                condition = "or";
                conditions = [
                  { condition = "time"; before = "2:00:00"; after = "1:00:00"; }
                  { condition = "time"; before = "5:00:00"; after = "4:00:00"; }
                  { condition = "time"; before = "8:00:00"; after = "7:00:00"; }
                  { condition = "time"; before = "11:00:00"; after = "10:00:00"; }
                  { condition = "time"; before = "14:00:00"; after = "13:00:00"; }
                  { condition = "time"; before = "17:00:00"; after = "16:00:00"; }
                  { condition = "time"; before = "20:00:00"; after = "19:00:00"; }
                  { condition = "time"; before = "23:00:00"; after = "22:00:00"; }
                ];
              }
            ];
            trigger = {
              platform = "time_pattern";
              hours = "*";
              minutes = "/30";
            };
            action = [{
              service = "switch.turn_off";
              target.entity_id = candle_switches;
            }];
          }
          {
            id = "handle_tag_scan";
            alias = "Handle Tag Scan";
            mode = "single";
            max_exceeded = "silent";
            variables = {
              # media_players = {
              #    SCANNER_ID => "playback.device"
              #   "ae114876cf32566742995fe050bdb55a" = "media_player.denon";
              # };
              tags = {
                "A4-B2-75-D5" = {
                  media_content_id = "https://open.spotify.com/track/6I9VzXrHxO9rA9A5euc8Ak";
                  media_content_type = "track";
                };
                "7C-3C-26-17" = {
                  # cascade trigger something else?
                };
              };
            };
            trigger = {
              platform = "event";
              event_type = "tag_scanned";
            };
            condition = [
              "{{ trigger.event.data.tag_id in tags }}"
              # "{{ trigger.event.data.device_id in media_players }}"
            ];
            action = [
              {
                service = "media_player.play_media";
                data = {
                  entity_id = "media_player.spotify_cole_mickens";
                  #entity_id = "{{ media_players[trigger.event.data.device_id] }}";
                  media_content_id = "{{ tags[trigger.event.data.tag_id].media_content_id }}";
                  media_content_type = "{{ tags[trigger.event.data.tag_id].media_content_type }}";
                };
              }
            ];
          }
        ];
        #cast = { media_player = { host = "192.168.1.200"; }; };
        #cloud = { };
        config = { };
        climate = { };
        ## default_config = { }; ## TODO?
        denonavr = { };
        #discovery = { };
        esphome = { };
        frontend = {
          themes = {
            midnight = import ./theme-midnight.nix;
            slate = import ./theme-slate.nix;
          };
        };
        history = { };
        http = {
          server_host = ha_host;
          server_port = ha_port;
          use_x_forwarded_for = true; # TODO nginx side?
          trusted_proxies = [
            # TODO TODO TODO
            "127.0.0.1"
            "::1"
          ];
        };
        # light = [
        #   {
        #     platform = "nanoleaf";
        #     host = "192.168.72.138";
        #     token = "xInHWS17zONcFiW5bpPXA7ZDYdWuFQP2";
        #   }
        # ];
        media_player = [
          {
            name = "braviatv";
            platform = "braviatv";
            host = "192.168.1.119";
          }
        ];
        nanoleaf = { };
        # prometheus = { namespace = "hass"; };
        ssdp = { };
        recorder = {
          purge_interval = 1;
          purge_keep_days = 30;
        };
        switch = [
          {
            platform = "wake_on_lan";
            name = "slywin";
            mac = "18-c0-4d-a0-8d-22";
          }
          {
            platform = "wake_on_lan";
            name = "pelinore";
            mac = "18-c0-4d-a1-57-91";
          }
        ];
        system_health = { };
        wake_on_lan = { };
        webostv = [
          {
            name = "LivingRoom_LG_C1";
            host = "192.168.5.202";
            turn_on_action.service = "wake_on_lan.send_magic_packet";
            turn_on_action.data.mac = "74-E6-B8-0E-BB-38";
          }
        ];
        # weather = {
        #   platform = "openweathermap";
        #   api_key = secrets.openweathermap_apikey;
        # };
        # zwave = { usb_path = zwaveAdapter; };
      };
      lovelaceConfig = import
        ./lovelace.nix;
      lovelaceConfigWritable = false;
    };
  };
}
