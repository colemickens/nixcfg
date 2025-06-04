{
  config,
  pkgs,
  lib,
  ...
}:

let
  _pushSettings = {
    filesystems = {
      "zephpool/root<" = true;
      "zephpool/home<" = true;
    };
    replication = {
      protection = {
        initial = "guarantee_resumability";
        incremental = "guarantee_incremental";
      };
    };
    send = {
      encrypted = false;
    };
    snapshotting = {
      type = "manual";
    };
    pruning = {
      keep_sender = [
        {
          type = "regex";
          regex = ".*";
        }
      ];
      keep_receiver = [
        {
          # TODO: we don't really need pruning for now probably
          type = "regex";
          regex = ".*";
        }
      ];
    };
  };
in
{
  config = {
    services.zrepl = {
      enable = true;
      settings = {
        jobs = [
          #
          # SNAPSHOT JOB
          {
            name = "snaplocal";
            type = "snap";
            filesystems = {
              "zephpool/root<" = true;
              "zephpool/home<" = true;
            };
            snapshotting = {
              type = "periodic";
              interval = "10m";
              prefix = "zrepl_snaplocal_";
            };
            pruning = {
              keep = [
                {
                  type = "grid";
                  # keep all created in last hour
                  # keep 168 (24*7) hourly snapshots
                  # keep 30 daily snapshots
                  # we can handle all of this locally, we can probably do more on the external drive sink
                  grid = "1x1h(keep=all) | 168x1h | 30x1d | 52x1w";
                  regex = "^zrepl_snaplocal_.*";
                }
                {
                  type = "regex";
                  negate = true;
                  regex = "^zrepl_snaplocal_.*";
                }
              ];
            };
          }

          # PUSH JOB (TCP->RAISIN)
          #
          (
            {
              name = "push_to_raisin";
              type = "push";
              connect = {
                type = "tcp";
                address = "100.112.194.64:8888";
                dial_timeout = "10s";
              };
            }
            // _pushSettings
          )

          #
          # PUSH JOB
          (
            {
              name = "push_to_orion";
              type = "push";
              connect = {
                type = "local";
                listener_name = "sink_orion";
                client_identity = "zeph";
              };
            }
            // _pushSettings
          )

          # #
          # # SINK JOB
          {
            name = "sink_orion";
            type = "sink";
            root_fs = "orionpool/backups";
            serve = {
              type = "local";
              listener_name = "sink_orion";
            };
          }
        ];
      };
    };
  };
}
