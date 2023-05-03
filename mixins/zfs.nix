{ pkgs, config, ... }:

let
  hn = config.networking.hostName;
  selfPools = [ "${config.networking.hostName}pool" ];
  customPools = {
    "xeep" = [ "tank2" ];
    "raisin" = [ "tank" ];
    "jeffhyper" = [ "rpool" ];
  };
  pools =
    if (builtins.hasAttr hn customPools)
    then customPools."${hn}"
    else selfPools;
in {
  config = {
    # run this to enable auto-trim on the pool:
    # `sudo zpool set autotrim=on TANK`

    # check if its enabled:
    # zpool get all | grep autotrim (also check if luks is allowDiscards)

    services.zfs = {
      trim.enable = true;
      autoScrub = {
        enable = true;
        pools = pools;
      };
      autoSnapshot = {
        enable = true;
        frequent = (24*4); # keep the latest eight 15-minute snapshots (instead of four)
        monthly = 12; # keep only one monthly snapshot (instead of twelve)
        hourly = 96;
        weekly = 8;
      };
    };
  };
}
