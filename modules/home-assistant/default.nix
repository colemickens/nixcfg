{ pkgs, ... }:

let
  trusted_networks = [
    "192.168.1.0/24" # default chimera network
    "192.168.2.0/24" # wireguard network
    #"192.168.69.0/24" # esphome network (but doesn't need to hit HA frontdoor)
  ];

  # hopefully removing this soon? vvv
  zwaveAdapter  = "/dev/serial/by-id/usb-Silicon_Labs_HubZ_Smart_Home_Controller_813003E3-if00-port0";
  zigbeeAdapter = "/dev/serial/by-id/usb-Silicon_Labs_HubZ_Smart_Home_Controller_813003E3-if01-port0";

  ha_host = "127.0.0.1";
  ha_port = 8123;
  ha_host_port = "${ha_host}:${toString ha_port}";
  ha_mqtt_username = "homeassistant";
  ha_mqtt_password = "homeassistant_password";

  ha_access_token_prometheus = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJmYTIyYTU4YTJkZDM0Y2YxYTU1NGJjOWJlN2Q0YmY1OSIsImlhdCI6MTU4MDE4MzExNCwiZXhwIjoxODk1NTQzMTE0fQ.ml0utOOLlrCdmiXWRxRf5rwsHBvjZBJ2Bpc-xzL2nSA";

  oh = "pslivaruemhjwytgi7apek6jkearbmpam54e6pvv2wlxgalve5ilefyd.onion";
in
{
  config = {
    networking.firewall = {
      allowedTCPPorts = [ ha_port ];
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
      domain = "grafana.${oh}";
      auth.anonymous.enable = true;
      provision = {
        enable = true;
        #dashboards = {
        #};
        datasources = [
          {
            name = "prometheus";
            url = "http://localhost:9090";
            type = "prometheus";
            access = "proxy";
          }
        ];
      };
    };

    services.home-assistant = {
      enable = true;
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
               trusted_networks = [ "127.0.0.1" ] ++ trusted_networks;
               allow_bypass_login = true;
             }
          ];
        };
        config = {}; # TODO: disable?
        frontend = {
          themes = {
            midnight = import ./theme-midnight.nix; # TODO: import vs copyToStore?
            slate = import ./theme-slate.nix;
          };
        };
        recorder = {};
        history = {};
        http = {
          server_host = "0.0.0.0";
          server_port = ha_port;
        };
        cast = {
          media_player = { host = "192.168.1.200"; };
        };
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
        system_health = {};
      };
      lovelaceConfig = import ./lovelace.nix;
      lovelaceConfigWritable = false;
    };
  };
}
