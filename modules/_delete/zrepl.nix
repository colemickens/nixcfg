# https://github.com/Baughn/machine-config/blob/3eed598f8b3b7fb6c7ab93615c2864f8e4652af4/modules/zrepl.nix
{ config, pkgs, lib, ... }:


{
  options = {
    services.zrepl = with lib; with types; {
        enable = mkEnableOption "zrepl";

        package = mkOption {
          description = "zrepl package";
          defaultText = "pkgs.zrepl";
          type = package;
          default = pkgs.callPackage ../zrepl {};
        };
        
        logging.level = mkOption {
          description = "Log level";
          example = "debug";
          type = string;
          default = "info";
        };

        monitoring.port = mkOption {
          description = "Prometheus monitoring port";
          type = nullOr int;
          default = 8549;
        };

        local = mkOption {
          default = {};
          type = attrsOf (submodule ({name, ...}: {
            options = {
              sourceFS = mkOption {
                description = "Root of ZFS dataset(s) to replicate";
                example = "replicated_pool/home";
                type = string;
              };
              targetFS = mkOption {
                description = "Root of ZFS dataset to write replication snapshots into.";
                example = "replicated_pool/zrepl";
                type = string;
              };
              exclude = mkOption {
                description = "List of ZFS dataset(s) NOT to replicate or snapshot";
                example = [ "replicated_pool/home/you/private" ];
                type = listOf string;
                default = [];
              };
              snapshotting = {
                prefix = mkOption {
                  description = "Snapshot name prefix";
                  default = "zrepl_";
                  type = string;
                };
                interval = mkOption {
                  description = "Time in minutes between snapshots";
                  default = 10;
                  type = int;
                };
              };
            };
          }));
          example = literalExample ''
            services.zrepl.local."backup_name" = {
              sourceFS = "fast_and_scary_pool/home";
              targetFS = "replicated_pool/zrepl";
            };
          '';
        };

        sink = mkOption {
          default = {};
          type = attrsOf (submodule ({name, ...}: {
            options = {
              targetFS = mkOption {
                description = "Root of ZFS dataset to write replication snapshots into.";
                example = "replicated_pool/zrepl";
                type = string;
              };
              port = mkOption {
                description = "Port on which to listen for zrepl connections.";
                type = int;
                default = 8550;
              };
              openFirewall = mkOption {
                description = "Automatically open a hole in the firewall.";
                type = bool;
                default = true;
              };
              clients = mkOption {
                description = "Client CNs to permit replication to this targetFS";
                defaultText = "[ <sink name> ]";
                default = [ name ];
                type = listOf string;
              };
            };
          }));
          example = literalExample ''
            services.zrepl.sink."pusher_name" = {
              targetFS = "replicated_pool/zrepl";
            };
          '';
        };

        push = mkOption {
          default = {};
          type = attrsOf (submodule {
            options = {
              sourceFS = mkOption {
                description = "Root of ZFS dataset(s) to replicate";
                example = "fast_and_scary_pool/home";
                type = string;
              };
              exclude = mkOption {
                description = "List of ZFS dataset(s) NOT to replicate or snapshot";
                example = [ "fast_and_scary_pool/home/you/private" ];
                type = listOf string;
                default = [];
              };
              targetHost = mkOption {
                description = "DNS name or IP address of machine to replicate to.";
                example = "example.org";
                type = string;
              };
              targetPort = mkOption {
                description = "Port to connect to. Ignored if targetHost is null.";
                type = int;
                default = 8550;
              };
              snapshotting = {
                prefix = mkOption {
                  description = "Snapshot name prefix";
                  default = "zrepl_";
                  type = string;
                };
                interval = mkOption {
                  description = "Time in minutes between snapshots";
                  default = 10;
                  type = int;
                };
              };
            };
          });
          example = literalExample ''
            services.zrepl.push."pusher_name" = {
              sourceFS = "replicated_pool/home";
              targetHost = "example.org";
            };
          '';
        };
      };
  };

  ### Implementation ###

  config = let
    cfg = config.services.zrepl;

    configFile = pkgs.runCommand "zrepl.yml" {
      inherit configuration;
      passAsFile = [ "configuration" ];
    } ''
      ${pkgs.jq}/bin/jq < "$configurationPath" > "$out"
    '';
    
    configuration = builtins.toJSON ({
      global.logging = [{
        format = "human";
        type = "stdout";
        level = cfg.logging.level;
      }];
      jobs = (lib.mapAttrsToList mkSinkJob cfg.sink)
        ++ (lib.mapAttrsToList mkPushJob cfg.push)
        ++ (lib.mapAttrsToList mkLocalPush cfg.local)
        ++ (lib.mapAttrsToList mkLocalSink cfg.local);
    } // (if cfg.monitoring.port != null then {
      global.monitoring = [{
        type = "prometheus";
        listen = ":${builtins.toString cfg.monitoring.port}";
      }];
    } else {}));

    mkSinkJob = name: sink: {
      name = "${name}_sink";
      type = "sink";
      root_fs = sink.targetFS;
      serve = {
        type = "tls";
        listen = ":${builtins.toString sink.port}";
        client_cns = sink.clients;
        ca = "/var/spool/zrepl/ca.crt";
        cert = "/var/spool/zrepl/${config.networking.hostName}.crt";
        key = "/var/spool/zrepl/${config.networking.hostName}.key";
      };
    };

    mkPushJob = name: push: {
      name = "${name}_push";
      type = "push";
      connect = {
        type = "tls";
        address = "${push.targetHost}:${builtins.toString push.targetPort}";
        ca = "/var/spool/zrepl/ca.crt";
        cert = "/var/spool/zrepl/${config.networking.hostName}.crt";
        key = "/var/spool/zrepl/${config.networking.hostName}.key";
        server_cn = name;
      };
      filesystems = filesystemsConfig push;
      snapshotting = snapshotConfig push;
      pruning = pruningConfig push;
    };

    mkLocalSink = name: sink: {
      name = "${name}_local_sink";
      type = "sink";
      root_fs = sink.targetFS;
      serve = {
        type = "local";
        listener_name = "${name}_local_listener";
      };
    };

    mkLocalPush = name: push: {
      name = "${name}_local_push";
      type = "push";
      connect = {
        type = "local";
        listener_name = "${name}_local_listener";
        client_identity = name;
      };
      filesystems = filesystemsConfig push;
      snapshotting = snapshotConfig push;
      pruning = pruningConfig push;
    };

    filesystemsConfig = push: {
      "${push.sourceFS}<" = true;
    } // (pkgs.lib.genAttrs push.exclude (fs: false));

    snapshotConfig = push: {
      type = "periodic";
      prefix = push.snapshotting.prefix;
      interval = "${builtins.toString push.snapshotting.interval}m";
    };

    pruningConfig = push: {
      # TODO: Add some configurability here.
      keep_sender = [{
        type = "not_replicated";
      }{
        type = "grid";
        grid = "1x3h(keep=all) | 24x1h | 7x1d";
        regex = "^${push.snapshotting.prefix}";
      }];
      keep_receiver = [{
        type = "grid";
        grid = "24x1h | 30x1d | 6x14d";
        regex = "^${push.snapshotting.prefix}";
      }];
    };

    byRootFs = { command, set, attribute}: lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: ''
      ${command} "${value.${attribute}}"
    '') set);
  in

  lib.mkIf cfg.enable {
    environment.etc."zrepl.yml".source = configFile;

    networking.firewall.allowedTCPPorts = builtins.filter (p: p != null) (
      lib.mapAttrsToList (name: sink: if sink.openFirewall then sink.port else null)
      cfg.sink);

    systemd.services.zrepl = {
      enable = cfg.enable;

      description = "ZFS Replication";
      documentation = [ "https://zrepl.github.io/" ];

      requires = [ "local-fs.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        #User = "zrepl";
      };

      path = [ cfg.package pkgs.zfs pkgs.super ];
      script = ''
        set -e

        HOME=/var/spool/zrepl

        # Create the directories, if needed.
        mkdir -pm 0770 $HOME /var/run/zrepl
        chown zrepl $HOME /var/run/zrepl

        cd $HOME

        if [[ ! -e ca.crt ]]; then
          echo 'You must manually create the certificate authority and host keys.'
          echo 'Look at https://zrepl.github.io/configuration/transports.html#transport-tcp-tlsclientauth-2machineopenssl'
          echo 'for instructions, and name them according to /etc/zrepl.yml.'
          echo 'We recommend the easyrsa package.'
          exit 1
        fi

        # Setup datasets & permissions
        setupSink() {
          if ! zfs list -H "$1"; then
            zfs create "$1" -o mountpoint=none
          fi
          # We do not intend to mount filesystems, and non-root users
          # anyway can't, but due to limitations in zfs-on-linux the user
          # still needs the permission.
          #
          # The mountpoint permission is needed because zrepl sets
          # mountpoint=none. It's a little bizarre, but there you go.
          zfs unallow -ldu zrepl "$1"
          zfs allow -ldu zrepl mount,clone,create,destroy,hold,promote,receive,release,rename,rollback,snapshot,bookmark,userprop,mountpoint "$1"
        }

        setupPush() {
          zfs unallow -ldu zrepl "$1"
          zfs allow -ldu zrepl mount,destroy,hold,promote,send,release,snapshot,bookmark,userprop "$1"
        }
      '' + byRootFs { command = "setupSink"; set=cfg.sink; attribute="targetFS"; }
         + byRootFs { command = "setupPush"; set=cfg.push; attribute="sourceFS"; }
         + byRootFs { command = "setupSink"; set=cfg.local; attribute="targetFS"; }
         + byRootFs { command = "setupPush"; set=cfg.local; attribute="sourceFS"; }
         + ''
           
        # Ensure ownership and permissions
        chown -R zrepl:root $HOME
        chmod -R o= $HOME

        # Start the daemon.
        exec setuid zrepl zrepl --config=/etc/zrepl.yml daemon
      '';
    };

    users.users.zrepl = {
      uid = 316;
      isSystemUser = true;
      home = "/var/spool/zrepl";
    };

    environment.systemPackages = [
      (pkgs.callPackage ../zrepl {})
    ];

    security.wrappers.zrepl-status.source = pkgs.stdenv.mkDerivation {
      name = "zrepl-status";
      unpackPhase = "true";
      installPhase = ''
        cat > zrepl-status.c <<'EOF'
          #include <unistd.h>
          #include <stdlib.h>
          #include <string.h>

          int main() {
            char *term = strdup(getenv("TERM"));
            clearenv();
            setenv("TERM", term, 1);

            return execl("${cfg.package}/bin/zrepl",
              "zrepl-status",
              "--config=/etc/zrepl.yml", "status", (char*)NULL);
          }
        EOF

        gcc zrepl-status.c -Os -o $out
      '';
    };
  };
}
