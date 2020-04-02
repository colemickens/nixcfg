{ pkgs, ... }:

let
  secrets = import ./secrets.nix;

  trusted_networks = [ "192.168.1.0/24" ];
  ha_host = "127.0.0.1";
  ha_port = 8123;
  ha_host_port = "${ha_host}:${toString ha_port}";
in {
  config = {
    networking.firewall = { allowedTCPPorts = [ ha_port ]; };
    services.home-assistant = {
      enable = true;
      port = ha_port;
      config = {
        homeassistant = {
          name = "GoonAssistant";
          time_zone = "US/Central";
          latitude = 38.9714;
          longitude = -95.6047;
          elevation = 323; # 323 m according to Google Earth
          unit_system = "imperial";
          temperature_unit = "F";
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

        alarmdecoder = {
          device = {
            type = "socket";
            host = "192.168.1.9";
            port = 10000;
          };
          panel_display = true;
          zones = {
            "01" = { name = "Unknown"; };
            "02" = {
              name = "DOOR: Kitchen";
              type = "door";
            };
            "03" = {
              name = "MOTION: Upstairs";
              type = "motion";
            };
            "04" = {
              name = "MOTION: Downstairs";
              type = "motion";
            };
            "05" = {
              name = "DOOR: Front";
              type = "door";
            };
            "06" = {
              name = "DOOR: Downstairs";
              type = "door";
            };
            # radio: 44: sliding door to patio
            # radio: 45: garage service door
          };
        };
        camera = [
          {
            platform = "onvif";
            host = "127.0.0.1";
            port = "5016";
            name = "Camera (Garage SE)";
            password = secrets.onvif_password;
          }
          {
            platform = "onvif";
            host = "127.0.0.1";
            port = "5017";
            name = "Camera (Patio East)";
            password = secrets.onvif_password;
          }
          {
            platform = "onvif";
            host = "127.0.0.1";
            port = "5018";
            name = "Camera (Garage SW)";
            password = secrets.onvif_password;
          }
          {
            platform = "onvif";
            host = "127.0.0.1";
            port = "5021";
            name = "Camera (Front Door)";
            password = secrets.onvif_password;
          }
          {
            platform = "onvif";
            host = "127.0.0.1";
            port = "5022";
            name = "Camera (Garage Back)";
            password = secrets.onvif_password;
          }
          {
            platform = "onvif";
            host = "127.0.0.1";
            port = "5023";
            name = "Camera (Patio West)";
            password = secrets.onvif_password;
          }
          {
            platform = "onvif";
            host = "127.0.0.1";
            port = "5024";
            name = "Camera (Basement)";
            password = secrets.onvif_password;
          }
        ];
        config = { };
        discovery = { };
        frontend = { };
        recorder = { };
        history = { };
        http = {
          server_host = "0.0.0.0";
          server_port = ha_port;
        };
        media_player = [
          {
            name = "denonavr_family_room";
            platform = "denonavr";
            host = "192.168.1.15";
          }
          {
            name = "denonavr_patio";
            platform = "denonavr";
            host = "192.168.1.19";
          }
        ];
        recorder = { };
        roku = [ { host = "192.168.1.3"; } { host = "192.168.1.5"; } ];
        plex = { token = secrets.plex_access_token; };
        system_health = { };
        weather = {
          platform = "openweathermap";
          api_key = secrets.openweathermap_apikey;
        };
      };
      lovelaceConfig = import ./lovelace.nix;
      lovelaceConfigWritable = false;
    };
  };
}
