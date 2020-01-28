{ pkgs, ... }:

let
  zwaveAdapter  = "/dev/serial/by-id/usb-Silicon_Labs_HubZ_Smart_Home_Controller_813003E3-if00-port0";
  zigbeeAdapter = "/dev/serial/by-id/usb-Silicon_Labs_HubZ_Smart_Home_Controller_813003E3-if01-port0";

  # chimera network
  # 192.168.1.0/17 = LAN
  # 192.168.128.0/24 = LAN2
  # 192.168.69.0/24 = WLAN(LAN) chimera-iot (static IOT ips)
  # 192.168.2.0/24 = WG (oops, overlaps LAN, we should fix that)

  # TODO:
  # - produce ESPHOME configs
  #   and a script to execute ESPHOME and burn devices
  # - try making more "networks" in unifi

  eth = "eth0";
  wg = "wg1";
  wg_port = 51820;
  mqtt_port = 1883;
  externalIP = "192.168.1.117";
  external_range = "192.168.1.0/24";
  internalIP = "192.168.2.1";
  internal_range = "192.168.2.0/24";

  ha_host = "127.0.0.1";
  ha_port = 8123;
  ha_host_port = "${ha_host}:${toString ha_port}";
  ha_mqtt_username = "homeassistant";
  ha_mqtt_password = "homeassistant_password";

  ha_access_token_prometheus = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJmYTIyYTU4YTJkZDM0Y2YxYTU1NGJjOWJlN2Q0YmY1OSIsImlhdCI6MTU4MDE4MzExNCwiZXhwIjoxODk1NTQzMTE0fQ.ml0utOOLlrCdmiXWRxRf5rwsHBvjZBJ2Bpc-xzL2nSA";

  mkSwitch = name:
    {
      name = "${name}";
      platform = "mqtt";
      state_topic = "stat/${name}/RESULT";
      value_template = "{{ value_json.POWER }}";
      command_topic = "cmnd/${name}/POWER";
      payload_on = "ON";
      payload_off = "OFF";
      availability_topic = "tele/${name}/LWT";
      payload_available = "Online";
      payload_not_available = "Offline";
      qos = 1;
      retain = false;
    };
in
{
  config = {
    networking.nat = {
      enable = true;
      internalInterfaces = [ wg ];
      internalIPs = [ internal_range ];
      externalInterface = eth;
      #externalIP = externalIP;
    };
    networking.firewall = {
      enable = true;
      allowedUDPPorts = [ wg_port mqtt_port ];
      allowedTCPPorts = [ ha_port mqtt_port ];
    };
    networking.wireguard.interfaces."${wg}" = {
      ips = [ internal_range ];
      listenPort = wg_port;
      privateKeyFile = "${../../machines/raspberry/wg-server.key}";
      peers = [
        { allowedIPs = ["192.168.2.2/32"]; # cole-phone
          publicKey = "TVmP+Ov/RKECq98pCpoTAgJF9BKo/QrUUN+25dEnjR4="; }
        { allowedIPs = ["192.168.2.3/32"]; # buddie-phone
          publicKey = "UrVPH3QQhRNCsLfM21gv08PydwrIV6eGuStKG8mn/CI="; }
        { allowedIPs = ["192.168.2.4/32"]; # cole-xeep
          publicKey = "tT5n9KdBwB53u1kFT25S9G4gKct3/Ruje9fDZk8fsGA="; }
      ];
    };


    services.tor.enable = true;
    services.tor.hiddenServices = {
      "ssh" = {
        name = "ssh";
        map = [{ port = "22"; }];
        version = 3;
      };
      "homeass" = {
        name = "home-assistant";
        map = [{ port = 80; toPort = ha_port; }];
        version = 3;
      };
      "router" = {
        name = "router";
        map = [{ port = 443; toPort = "8443"; }];
        version = 3;
      };
    };

    services.prometheus = {
      enable = true;
      scrapeConfigs = [
        {
          job_name = "home-assistant-scrape";
          scrape_interval = "30s";
          metrics_path = "/api/prometheus";
          bearer_token = ha_access_token_prometheus;
          scheme = "http";
          static_configs = [ { targets = [ha_host_port]; } ]; # add ${ha_host}
        }
      ];
      exporters = {
        node = { enable = true; enabledCollectors = [ "systemd" ]; };
        tor = { enable = true; };
        #unifi =  {
        #  enable = true; 
        #  unifiInsecure = true;
        #  unifiAddress = "https://127.0.0.1:8443";
        #  unifiUsername = "admin";
        #  unifiPassword = "foo";
        #};
      };
    };
    services.grafana = {
      enable = true;
      provision = {
        #dashboards = {
        #};
        datasources = [
        ];
      };
      security = {
        adminUser = "admin";
        adminPassword = "admin";
      };
    };

    environment.systemPackages = with pkgs; [
      mosquitto home-assistant-cli
    ];
    services.mosquitto = {
      enable = true;
      allowAnonymous = true;
      host = "0.0.0.0";
      port = mqtt_port;
      # TODO: clamp down permissions!
      users = {
        "${ha_mqtt_username}" = {
          acl = [ "topic readwrite #" ];
          password = ha_mqtt_password;
        };
        "DVES_USER" = {
          acl = [ "topic readwrite #" ];
          password = "DVES_PASSWORD";
        };
      };
    };
    services.home-assistant = {
      enable = true;
      package = pkgs.home-assistant.override {
        extraPackages = ps: with ps; [
          colorlog
          zigpy

          # should come from components after parse-reqs in nixpkgs
          #getmac    # needed for "braviatv" type
          #denonavr  # needed for "denonavr" type
          #braviarc  # needed for "braviatv" type
          #flux-led  # needed for light->flux_led type

          #bellows   # needed for zha (zigbee)
          #hbmqtt    # ??
        ];
      };
      port = 8123;
      config = {
        homeassistant = {
          name = "ChimeraHomeAssistant";
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
               trusted_networks = [ "127.0.0.1" external_range internal_range ];
               allow_bypass_login = true;
             }
          ];
        };
        config = {};
        frontend = {
          themes = {
            midnight = {
              primary-color = "#5294E2";
              accent-color = "#E45E65";
              dark-primary-color = "var(--accent-color)";
              light-primary-color = "var(--accent-color)";

              primary-text-color = "#FFFFFF";
              text-primary-color = "var(--primary-text-color)";
              secondary-text-color = "#5294E2";
              disabled-text-color = "#7F848E";
              label-badge-border-color = "green";

              primary-background-color = "#383C45";
              secondary-background-color = "#383C45";
              divider-color = "rgba(0, 0, 0, .12)";

              table-row-background-color = "#353840";
              table-row-alternative-background-color = "#3E424B";

              paper-listbox-color = "var(--primary-color)";
              paper-listbox-background-color = "#2E333A";
              paper-grey-50 = "var(--primary-text-color)";
              paper-grey-200 = "#414A59";

              paper-card-header-color = "var(--accent-color)";
              paper-card-background-color = "#434954";
              paper-dialog-background-color = "#434954";
              paper-item-icon-color = "var(--primary-text-color)";
              paper-item-icon-active-color = "#F9C536";
              paper-item-icon_-_color = "green";
              paper-item-selected_-_background-color = "#434954";
              paper-tabs-selection-bar-color = "green";

              label-badge-red = "var(--accent-color)";
              label-badge-text-color = "var(--primary-text-color)";
              label-badge-background-color = "#2E333A";

              paper-toggle-button-checked-button-color = "var(--accent-color)";
              paper-toggle-button-checked-bar-color = "var(--accent-color)";
              paper-toggle-button-checked-ink-color = "var(--accent-color)";
              paper-toggle-button-unchecked-button-color = "var(--disabled-text-color)";
              paper-toggle-button-unchecked-bar-color = "var(--disabled-text-color)";
              paper-toggle-button-unchecked-ink-color = "var(--disabled-text-color)' ";

              paper-slider-knob-color = "var(--accent-color)";
              paper-slider-knob-start-color = "var(--accent-color)";
              paper-slider-pin-color = "var(--accent-color)";
              paper-slider-active-color = "var(--accent-color)";
              paper-slider-container-color = "linear-gradient(var(--primary-background-color), var(--secondary-background-color)) no-repeat";
              paper-slider-secondary-color = "var(--secondary-background-color)";
              paper-slider-disabled-active-color = "var(--disabled-text-color)";
              paper-slider-disabled-secondary-color = "var(--disabled-text-color)";

              google-red-500 = "#E45E65";
              google-green-500 = "#39E949";
            };
          };
        };
        mobile_app = {};
        http = {
          server_host = "0.0.0.0";
          server_port = ha_port;
        };
        cast = {
          media_player = { host = "192.168.1.200"; };
        };
        #light = [
        #  (let dev = "iot_mh_led"; in {
        #    platform = "mqtt";
        #    name = dev;
        #    command_topic = "cmnd/${dev}/POWER";
        #    state_topic = "tele/${dev}/STATE";
        #    state_value_template = "{{value_json.POWER}}";
        #    availability_topic = "tele/${dev}/LWT";
        #    brightness_command_topic = "cmnd/${dev}/Dimmer";
        #    brightness_state_topic = "tele/${dev}/STATE";
        #    brightness_scale = 100;
        #    on_command_type = "brightness";
        #    brightness_value_template = "{{value_json.Dimmer}}";

        #    rgb_command_topic = "cmnd/${dev}/Color2";
        #    rgb_state_topic = "tele/${dev}/STATE";
        #    rgb_value_template = "{{value_json.Color.split(',')[0:3]|join(',')}}";
        #    effect_command_topic = "cmnd/${dev}/Scheme";
        #    effect_state_topic = "tele/${dev}/STATE";
        #    effect_value_template = "{{value_json.Scheme}}";
        #    effect_list = [ 0 1 2 3 4 ];

        #    payload_on = "ON";
        #    payload_off = "OFF";
        #    payload_available = "Online";
        #    payload_not_available = "Offline";
        #    qos = 1;
        #    retain = false;
        #  })
        #];
        zwave = { usb_path = zwaveAdapter; };
        #zha = { usb_path = zigbeeAdapter; };
        media_player = [
          { name = "braviatv"; platform = "braviatv"; host = "192.168.1.119"; }
          { name = "denonavr"; platform = "denonavr"; host = "192.168.1.126"; }
        ];
        plex = { token = "w3x73gRi5_KBB3ahxcnx"; };
        prometheus = {
          namespace = "hass";
        };
        esphome = {};
        mqtt = {
          broker = "127.0.0.1";
          username = ha_mqtt_username;
          password = ha_mqtt_password;
        };
        switch = [
          (mkSwitch "iot_wp6_buddie_lamp")
          (mkSwitch "iot_wp6_dab_rig")
          (mkSwitch "iot_wp6_den_lamp")
          (mkSwitch "iot_wp6_misc")
        ];
        system_health = {};
      };
      lovelaceConfig = {
        title = "Chimera Home";
        views = [
          {
            title = "Chimera Devices";
            cards = [
              {
                title = "Living Room";
                type = "entities";
                entities = [
                  { name="Fireplace";
                    entity = "switch.ge_14291_in_wall_smart_switch_switch"; }
                  { name="TV";
                    entity = "media_player.denonavr"; }
                  { name="Receiver";
                    entity = "media_player.braviatv"; }
                ];
              }
              {
                title = "Buddie's Desk";
                type = "entities";
                entities = [
                  { name = "Desk Lamp";
                    entity = "switch.iot_wp6_buddie_lamp"; }
                ];
              }
              {
                title = "Bed Room";
                type = "entities";
                entities = [
                ];
              }
              {
                title = "Den";
                type = "entities";
                entities = [
                  { name = "Den Lamp";
                    entity = "switch.iot_wp6_den_lamp"; }
                  { name = "Dab Rig";
                    entity = "switch.iot_wp6_dab_rig"; }
                  { name = "Misc";
                    entity = "switch.iot_wp6_misc"; }
                  { name = "Light Strip";
                    entity = "light.iot_mh_led"; }
                ];
              }
            ];
          }
        ];
      };
      lovelaceConfigWritable = false;
    };
  };
}

