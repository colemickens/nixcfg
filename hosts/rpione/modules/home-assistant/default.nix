{ pkgs, ... }:

let
  secrets = import ./secrets.nix;
  trusted_networks = [
    "192.168.1.0/24" # default chimera network
    "172.27.66.0/24" # wireguard network
    #"192.168.69.0/24" # esphome network (but doesn't need to hit HA frontdoor)
  ];

  ha_host = "127.0.0.1";
  ha_port = 8123;
  ha_host_port = "${ha_host}:${toString ha_port}";
in {
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
      enable = false;
      port = 8123;
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

        #cast = { media_player = { host = "192.168.1.200"; }; };
        #cloud = { };
        config = { };
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
          server_host = "0.0.0.0";
          server_port = ha_port;
        };
        media_player = [
          {
            name = "braviatv";
            platform = "braviatv";
            host = "192.168.1.119";
          }
        ];
        #mobile_app = {}; # needs hass_nabucasa or w/e
        # prometheus = { namespace = "hass"; };
        ssdp = { };
        recorder = { };
        system_health = { };
        # weather = {
        #   platform = "openweathermap";
        #   api_key = secrets.openweathermap_apikey;
        # };
        # zwave = { usb_path = zwaveAdapter; };
      };
      lovelaceConfig = import ./lovelace.nix;
      lovelaceConfigWritable = false;
    };
  };
}
