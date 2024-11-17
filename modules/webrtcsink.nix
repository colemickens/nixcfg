{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.services.webrtcsink;

  servercfg = "#TODO write config file";
  mkPubCfg = name: "# TODO: write config file";
in
# TODO:
# - how do we handle separation of webrtc/http? how does http find out
#   without... you know... needing ws? I guess the backend can talk ws to {ws_uri}
{
  options = {
    services.webrtcsink = {

      server-ws = lib.mkOption {
        types = types.submodule {
          enable = mkEnableOption "OpenCast WS Server";
          listen_uri = {
            type = types.str;
            default = "ws://localhost:10080";
          };
          debug = {
            type = types.bool;
            default = false;
          };
        };
      };

      server-http = lib.mkOption {
        types = types.submodule {
          enable = mkEnableOption "OpenCast HTTP Server";
          listen_uri = {
            type = types.str;
            default = "ws://localhost:10080";
          };
          debug = {
            type = types.bool;
            default = false;
          };
        };
      };

      publishers = lib.mkOption {
        type = types.attrsOf submodule ({
          # mkOption open_firewall?
          server_uri = {
            type = types.str;
            default = "ws://localhost:10443";
          };
          type = {
            type = types.str;
            default = "custom";
          };
          config = {
            type = types.attrset;
            default = { };
          };
          debug = {
            type = types.bool;
            default = false;
          };
        });
      };
    };
  };

  # implementation
  config = {
    system.services = lib.mkMerge [
      (mkIf cfg.server.enable {
        "opencast-ws@${pubname}" = {
          wantedBy = [ ];
          after = [ ];
          serviceConfig = {
            ExecStart = [ "${pkgs.opencast}/bin/opencast-ws --config ${servercfg}" ];
          };
        };
        "opencast-http@${pubname}" = {
          wantedBy = [ ];
          after = [ ];
          serviceConfig = {
            ExecStart = [ "${pkgs.opencast}/bin/opencast-http --config ${servercfg}" ];
          };
        };
      })
      (mkIf cfg.client.enable (
        lib.mkMerge [
          (lib.mapAttrs' (pubname: pubcfg: {
            "opencast-publisher@${pubname}" = {
              wantedBy = [ ];
              after = [ ];
              serviceConfig = {
                ExecStart = [ "${pkgs}/bin/opencast-publish --config ${mkPubCfg pubname}" ];
              };
            };
          }) cfg.client.publishers)
        ]
      ))
    ];
  };
}

# ({
#   "webrtcsink-publisher@" = {
#     wantedBy = [ ];
#     after = [ ];
#     serviceConfig = {
#       ExecStart = [
#         "${pkgs}/bin/webrtcsink-publish %I"
#       ];
#     };
#   };
# })
