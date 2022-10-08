{ pkgs, ... }:

# TODO: share trusted networks with nginx

let
  secrets = import ./secrets.nix;
  trusted_networks = [
    "192.168.0.0/16" # default chimera network
    "100.64.0.0/10" # tailscale network
    "fd7a:115c:a1e0:ab12:0000:0000:0000:0000/64"
  ];

  ha_host = "0.0.0.0";
  ha_port = 8123;
  # ha_host_port = "${ha_host}:${toString ha_port}";

  nanoleaf_light = "light.nanoleaf_light_panels_5b_38_ef";
  cleo_lamp_switch = "switch.wp6_sw102_relay";
  candle_switches = [
    "switch.wp6_sw105_relay" # den-bathroom
    "switch.wp6_sw107_relay" # candle1
    "switch.wp6_sw108_relay" # candle2
    "switch.wp6_sw109_relay" # candle3
  ];
  
  _ent = rec {
    lgc1 = "media_player.lg_webos_smart_tv";
    bravia = "media_player.braviatv";
    denon = "media_player.denon";

    nanoleaf = "light.nanoleaf_light_panels_5b_38_ef";
    
    slywin_wol = "switch.slywin";
    cleo_lamp = "switch.wp6_sw102_relay";
    cleo_fountain = "switch.wp6_sw104_relay";
    dabrig = "switch.wp6_sw103_relay";
    project_powerstrip = "switch.wp6_sw106_relay";

    candle_den_bath = "switch.wp6_sw105_relay";
    candle_1 = "switch.wp6_sw107_relay";
    candle_2 = "switch.wp6_sw108_relay";
    candle_3 = "switch.wp6_sw109_relay";
    _all_candles = [ candle_den_bath candle_1 candle_2 candle_3 ];
  };
in
{
  config = {
    networking.firewall = { allowedTCPPorts = [ ha_port ]; };

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

        script = {
          lgc1_screen_on.sequence = [{
            service = "webostv.command";
            target.entity_id = "media_player.lg_webos_smart_tv";
            data.command = "com.webos.service.tvpower/power/turnOnScreen";
          }];
          lgc1_screen_off.sequence = [{
            service = "webostv.command";
            target.entity_id = "media_player.lg_webos_smart_tv";
            data.command = "com.webos.service.tvpower/power/turnOffScreen";
          }];
          lgc1_open_youtube.sequence = [{
            service = "webostv.command";
            target.entity_id = "media_player.lg_webos_smart_tv";
            data.payload.id = "youtube.leanback.v4";
            data.command = "system.launcher/launch";
          }];
          lgc1_open_spotify.sequence = [{
            service = "webostv.command";
            target.entity_id = "media_player.lg_webos_smart_tv";
            data.payload.id = "spotify-beehive";
            data.command = "system.launcher/launch";
          }];
          lgc1_open_plex.sequence = [{
            service = "webostv.command";
            target.entity_id = "media_player.lg_webos_smart_tv";
            data.payload.id = "cdp-30";
            data.command = "system.launcher/launch";
          }];
          lgc1_open_pc.sequence = [{
            service = "media_player.select_source";
            entity_id = "media_player.lg_webos_smart_tv";
            data.source = "PC";
          }];
          lgc1_open_switch.sequence = [{
            service = "media_player.select_source";
            entity_id = "media_player.lg_webos_smart_tv";
            data.source = "Switch";
          }];
          # lgc1_open_gallery.sequence = [{
          #   # com.webos.app.igallery
          #   # com.webos.app.screensaver
          # }];
          bedtime.sequence = [
            {
              service = "media_player.turn_off";
              target.entity_id = "media_player.lg_webos_smart_tv";
            }
            {
              service = "media_player.turn_off";
              target.entity_id = "media_player.braviatv";
            }
            {
              service = "switch.turn_off";
              target.entity_id = "switch.wp6_sw103_relay";
            }
            {
              service = "switch.turn_off";
              target.entity_id = "switch.wp6_sw106_relay";
            }
            {
              service = "light.turn_on";
              target.entity_id = nanoleaf_light;
              data.brightness_pct = 20;
              data.rgb_color = [ 255 0 0 ];
            }
            {
              delay.minutes = 20;
            }
            {
              service = "light.turn_off";
              target.entity_id = nanoleaf_light;
            }
          ];
          morning.sequence = [
            {
              service = "light.turn_on";
              target.entity_id = nanoleaf_light;
              data.brightness_pct = 20;
              data.rgb_color = [ 255 255 255 ];
            }
            {
              delay.minutes = 30;
            }
            {
              service = "light.turn_on";
              target.entity_id = nanoleaf_light;
              data.brightness_pct = 100;
              data.rgb_color = [ 255 255 255 ];
            }
            {
              delay.minutes = 30;
            }
            {
              service = "light.turn_on";
              target.entity_id = nanoleaf_light;
              data.brightness_pct = 100;
              data.effect = "Paint Splatter";
            }
            {
              service = "media_player.turn_on";
              target.entity_id = "media_player.braviatv";
            }
            # {
            #   service = "media_player.turn_on";
            #   target.entity_id = "media_player.lg_webos_smart_tv";
            # }
            {
              delay.seconds = 15;
            }
            # {
            #   service = "script.turn_on";
            #   entity_id = "script.lgc1_open_gallery";
            # }
            # TODO: navigate the gallery, I guess?
            # TODO: how to do spotify simultaenously? I don't think we can... so homie-cast??
          ];
        };

        automation = [
          {
            id = "lgc1_wol";
            alias = "lgc1_wol";
            mode = "single";
            trigger = {
              platform = "webostv.turn_on";
              entity_id = "media_player.lg_webos_smart_tv";
            };
            action = [{
              service = "wake_on_lan.send_magic_packet";
              data.mac = "74-E6-B8-0E-BB-38";
            }];
          }
          {
            id = "morning";
            alias = "morning";
            mode = "single";
            trigger = {
              platform = "time_pattern";
              hours = "7";
              minutes = "00";
            };
            action = [{
              service = "script.turn_on";
              target.entity_id = "script.morning";
            }];
          }
          # TODO: think of something better for her lamp...
          # I think the lamp should be manual for blinds+ambient light
          # but I want something to ramp up around her food times...
          {
            id = "cleo_lamp_on";
            alias = "Cleo Lamp On";
            mode = "single";
            trigger = {
              platform = "time";
              at = [ "19:00:00" ];
            };
            action = [{
              service = "switch.turn_on";
              target.entity_id = cleo_lamp_switch;
            }];
          }
          {
            id = "cleo_lamp_off";
            alias = "Cleo Lamp Off";
            mode = "single";
            trigger = {
              platform = "time";
              at = [ "7:00:00" ];
            };
            action = [{
              service = "switch.turn_off";
              target.entity_id = cleo_lamp_switch;
            }];
          }
          # {
          #   id = "cleo_fountain_cycle";
          #   alias = "Cleo Fountain Cycle";
          #   mode = "single";
          #   trigger = {
          #     platform = "time_pattern";
          #     hours = "/1";
          #     minutes = "0";
          #   };
          #   action = [
          #     {
          #       service = "switch.turn_off";
          #       target.entity_id = _ent.cleo_fountain;
          #     }
          #     {
          #       delay.seconds = 2;
          #     }
          #     {
          #       service = "switch.turn_on";
          #       target.entity_id = _ent.cleo_fountain;
          #     }
          #   ];
          # }
          {
            id = "candles_on";
            alias = "Candles On";
            mode = "single";
            trigger = {
              platform = "time";
              at = [ "00:00:00" "6:00:00" "12:00:00" "18:00:00" ];
            };
            action = [{
              service = "switch.turn_on";
              target.entity_id = candle_switches;
            }];
          }
          {
            id = "candles_off";
            alias = "Candles Off";
            mode = "single";
            trigger = {
              platform = "time";
              at = [ "2:00:00" "8:00:00" "14:00:00" "20:00:00" ];
            };
            action = [{
              service = "switch.turn_off";
              target.entity_id = candle_switches;
            }];
          }
          # {
          #   id = "handle_tag_scan";
          #   alias = "Handle Tag Scan";
          #   mode = "single";
          #   max_exceeded = "silent";
          #   variables = {
          #     # media_players = {
          #     #    SCANNER_ID => "playback.device"
          #     #   "ae114876cf32566742995fe050bdb55a" = "media_player.denon";
          #     # };
          #     tags = {
          #       "A4-B2-75-D5" = {
          #         media_content_id = "https://open.spotify.com/track/6I9VzXrHxO9rA9A5euc8Ak";
          #         media_content_type = "track";
          #       };
          #       "7C-3C-26-17" = {
          #         # cascade trigger something else?
          #       };
          #     };
          #   };
          #   trigger = {
          #     platform = "event";
          #     event_type = "tag_scanned";
          #   };
          #   condition = [
          #     "{{ trigger.event.data.tag_id in tags }}"
          #     # "{{ trigger.event.data.device_id in media_players }}"
          #   ];
          #   action = [
          #     {
          #       service = "media_player.play_media";
          #       data = {
          #         entity_id = "media_player.spotify_cole_mickens";
          #         #entity_id = "{{ media_players[trigger.event.data.device_id] }}";
          #         media_content_id = "{{ tags[trigger.event.data.tag_id].media_content_id }}";
          #         media_content_type = "{{ tags[trigger.event.data.tag_id].media_content_type }}";
          #       };
          #     }
          #   ];
          # }
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
          # themes = {
          #   midnight = import ./theme-midnight.nix;
          #   slate = import ./theme-slate.nix;
          # };
        };
        # history = { };
        http = {
          server_host = ha_host;
          server_port = ha_port;
          use_x_forwarded_for = true;
          trusted_proxies = [ "127.0.0.1" "::1" ];
        };
        # light = [
        #   {
        #     platform = "nanoleaf";
        #     host = "192.168.72.138";
        #     token = "xInHWS17zONcFiW5bpPXA7ZDYdWuFQP2";
        #   }
        # ];
        # media_player = [
        #   {
        #     name = "braviatv";
        #     platform = "braviatv";
        #     host = "192.168.1.119";
        #   }
        # ];
        braviatv = {};
        nanoleaf = { };
        # prometheus = { namespace = "hass"; };
        ssdp = { };
        # recorder = {
        #   purge_interval = 1;
        #   purge_keep_days = 30;
        # };
        switch = [
          {
            platform = "wake_on_lan";
            name = "slywin";
            mac = "18-c0-4d-a0-8d-22";
          }
        ];
        system_health = { };
        wake_on_lan = { };
        webostv = { }; # TODO: it whines about this, but we need it to pull in pip pkgs
        # weather = {
        #   platform = "openweathermap";
        #   api_key = secrets.openweathermap_apikey;
        # };
      };
      lovelaceConfigWritable = false;
      lovelaceConfig = {
        title = "Chimera HomeAss";
        views = [
          {
            title = "Home";
            cards = [
              {
                title = "Living Room";
                type = "entities";
                entities = [
                  {
                    type = "section";
                    label = "Air Conditioner";
                  }
                  {
                    entity = "climate.ac";
                  }
                  {
                    type = "section";
                    label = "Television";
                  }
                  {
                    name = "LG C1 65";
                    entity = "media_player.lg_webos_smart_tv";
                  }
                  {
                    type = "buttons";
                    entities = [
                      {
                        entity = "script.lgc1_screen_on";
                        tap_action.action = "call-service";
                        tap_action.service = "script.lgc1_screen_on";
                        name = "on";
                        icon = "mdi:television";
                      }
                      {
                        entity = "script.lgc1_screen_off";
                        tap_action.action = "call-service";
                        tap_action.service = "script.lgc1_screen_off";
                        icon = "mdi:television-off";
                        name = "off";
                      }
                      {
                        entity = "script.lgc1_open_youtube";
                        tap_action.action = "call-service";
                        tap_action.service = "script.lgc1_open_youtube";
                        icon = "mdi:drama-masks";
                        name = "youtube";
                      }
                      {
                        entity = "script.lgc1_open_plex";
                        tap_action.action = "call-service";
                        tap_action.service = "script.lgc1_open_plex";
                        icon = "mdi:movie-open-outline";
                        name = "plex";
                      }
                      {
                        entity = "script.lgc1_open_spotify";
                        tap_action.action = "call-service";
                        tap_action.service = "script.lgc1_open_spotify";
                        icon = "mdi:music";
                        name = "spotify";
                      }
                      {
                        entity = "script.lgc1_open_pc";
                        tap_action.action = "call-service";
                        tap_action.service = "script.lgc1_open_pc";
                        icon = "mdi:desktop-classic";
                        name = "pc";
                      }
                      {
                        entity = "script.lgc1_open_switch";
                        tap_action.action = "call-service";
                        tap_action.service = "script.lgc1_open_switch";
                        icon = "mdi:controller-classic";
                        name = "switch";
                      }
                    ];
                  }

                  {
                    type = "section";
                    label = "Computer";
                  }

                  {
                    name = "slywin";
                    entity = "switch.slywin";
                  }

                  {
                    type = "section";
                    label = "Receiver";
                  }
                  {
                    name = "Denon AVR1913";
                    entity = "media_player.denon";
                  }
                ];
              }

              {
                title = "Kitchen Table";
                type = "entities";
                entities = [
                  {
                    type = "section";
                    label = "Television";
                  }
                  {
                    name = "Sony Bravia 55";
                    entity = "media_player.braviatv";
                  }
                  {
                    name = "Dab Rig";
                    entity = _ent.dabrig;
                  }
                  {
                    type = "section";
                    label = "Cleo";
                  }
                  {
                    name = "Cleo Lamp";
                    entity = "switch.wp6_sw102_relay";
                    icon = "mdi:lightbulb";
                  }
                ];
              }

              {
                title = "Bedroom";
                type = "entities";
                entities = [
                  {
                    name = "Nanoleaf △  Lights";
                    entity = "light.nanoleaf_light_panels_5b_38_ef";
                  }
                  {
                    type = "buttons";
                    entities = (
                      let mkButton = effect: rec {
                        type = "button";
                        entity = "light.nanoleaf_light_panels_5b_38_ef";
                        tap_action.action = "call-service";
                        tap_action.service = "light.turn_on";
                        tap_action.data.entity_id = entity;
                        tap_action.data.brightness_pct = 100;
                        tap_action.data.effect = effect;
                        name = effect;
                      }; in
                      [
                        (mkButton "Paint Splatter")
                        (mkButton "Northern Lights")
                        (mkButton "moonlight")
                        (mkButton "Tachyon Light2")
                        (mkButton "Twinkling Midnight Sky")
                        (mkButton "TV Simulation")
                        (mkButton "Disco Color")
                        (mkButton "Vaporwave")
                        (mkButton "Sunset")
                        (mkButton "Single fade")
                      ]
                    );
                  }
                ];
              }
            ];
          }

          {
            title = "Routines";
            cards = [
              {
                title = "Routines";
                type = "entities";
                entities = [
                  {
                    type = "buttons";
                    entities = [
                      {
                        entity = "script.bedtime";
                        tap_action.action = "call-service";
                        tap_action.service = "script.bedtime";
                        name = "sleep";
                        icon = "mdi:sleep";
                      }
                    ];
                  }
                ];
              }
            ];
          }

          {
            title = "Projects";
            cards = [
              {
                title = "Projects";
                type = "entities";
                entities = [
                  {
                    name = "powerstrip";
                    entity = "switch.wp6_sw106_relay";
                  }
                ];
              }
            ];
          }

          {
            title = "Automations";
            cards = [
              {
                title = "Automations";
                type = "entities";
                entities = [
                  "automation.morning"
                  "automation.candles_off"
                  "automation.candles_on"
                ];
              }
              {
                title = "Candles";
                type = "entities";
                entities = [
                  { name = "Bathroom-Den"; entity = "switch.wp6_sw105_relay"; }
                  { name = "Plant Shelf"; entity = "switch.wp6_sw107_relay"; }
                  { name = "Bedroom"; entity = "switch.wp6_sw108_relay"; }
                  { name = "Bathroom"; entity = "switch.wp6_sw109_relay"; }
                ];
              }
            ];
          }
        ];
      };
    };
  };
}
