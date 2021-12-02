{ pkgs, config, ... }:

{
  config = {
    # run this to enable auto-trim on the pool:
    # `sudo zpool set autotrim=on TANK`

    # check if its enabled:
    # zpool get all | grep autotrim (also check if luks is allowDiscards)

    services.zfs.trim.enable = true;

    services.zfs.autoSnapshot = {
      enable = true;
      frequent = 8; # keep the latest eight 15-minute snapshots (instead of four)
      monthly = 1;  # keep only one monthly snapshot (instead of twelve)
    };
  };
}
