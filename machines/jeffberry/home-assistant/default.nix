{ pkgs, ... }:

let
  trusted_networks = [
    "192.168.1.0/24" # default chimera network
    "192.168.2.0/24" # wireguard network
    #"192.168.69.0/24" # esphome network (but doesn't need to hit HA frontdoor)
  ];

  # hopefully removing this soon? vvv
  zwaveAdapter =
    "/dev/serial/by-id/usb-Silicon_Labs_HubZ_Smart_Home_Controller_813003E3-if00-port0";
  zigbeeAdapter =
    "/dev/serial/by-id/usb-Silicon_Labs_HubZ_Smart_Home_Controller_813003E3-if01-port0";

  ha_host = "127.0.0.1";
  ha_port = 8123;
  ha_host_port = "${ha_host}:${toString ha_port}";
  ha_mqtt_username = "homeassistant";
  ha_mqtt_password = "homeassistant_password";

  ha_access_token_prometheus =
    "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJmYTIyYTU4YTJkZDM0Y2YxYTU1NGJjOWJlN2Q0YmY1OSIsImlhdCI6MTU4MDE4MzExNCwiZXhwIjoxODk1NTQzMTE0fQ.ml0utOOLlrCdmiXWRxRf5rwsHBvjZBJ2Bpc-xzL2nSA";

  oh = "pslivaruemhjwytgi7apek6jkearbmpam54e6pvv2wlxgalve5ilefyd.onion";
in {
  config = {
    networking.firewall = { allowedTCPPorts = [ ha_port ]; };
    services.home-assistant = {
      enable = true;
      port = 8123;
      config = {
        homeassistant = {
          name = "BigGoonAssistant";
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
        config = { };
        frontend = { };
        recorder = { };
        history = { };
        http = {
          server_host = "0.0.0.0";
          server_port = ha_port;
        };
        roku = { host = "192.168.1.18"; };
        # TODO: what kind of receiver does he have
        # TODO: what kind of rokus, what ips?
        # TODO: what kind of TV?
        # TODO: get plex token somehow?
        # media_player = [
        #   {
        #     name = "braviatv";
        #     platform = "braviatv";
        #     host = "192.168.1.119";
        #   }
        #   {
        #     name = "denonavr";
        #     platform = "denonavr";
        #     host = "192.168.1.126";
        #   }
        # ];
        plex = { token = "w3x73gRi5_KBB3ahxcnx"; };
        system_health = { };
      };
      lovelaceConfig = import ./lovelace.nix;
      lovelaceConfigWritable = false;
    };
  };
}
