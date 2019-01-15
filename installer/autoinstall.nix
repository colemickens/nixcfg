{ config, pkgs, lib, ... }:

# EACH COMPUTER/DRIVE LAYOUT:
# |--------------------|-------------|-------------|-------------|--------------------------------------|
# |--------------------|-------------|-------------|-------------|--------------------------------------|
# | PARTITION          | [XEEP]      | [SLY]       | [CHIMERA]   |  PART TYPE                           |
# |--------------------|-------------|-------------|-------------|--------------------------------------|
# | 1) ESP (FAT32)     | 512 MB      | 512 MB      | 512MB       | C12A7328-F81F-11D2-BA4B-00A0C93EC93B |
# |--------------------|-------------|-------------|-------------|--------------------------------------|
# | 2) LUKS (BTRFS)    | (remainder) | (remainder) | (remainder) | CA7D7CCB-63ED-4C53-861C-1742536059CC |
# |--------------------|-------------|-------------|-------------|--------------------------------------|
# | 3) WinRE (NTFS)    | 512 MB      | 512 MB      |             | DE94BBA4-06D1-4D40-A16A-BFD50179D6AC |
# |--------------------|-------------|-------------|             |--------------------------------------|
# | 4) MS Reserved     | 128 MB      | 128 MB      |             | E3C9E316-0B5C-4DB8-817D-F92DF00215AE |
# |--------------------|-------------|-------------|             |--------------------------------------|
# | 5) Win10 (NTFS)    | 220GB        | 220GB       |             | EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 |
# |--------------------|-------------|-------------|-------------|--------------------------------------|
# |--------------------|-------------|-------------|-------------|--------------------------------------|
# |              TOTAL | 1 TB        | 250 GB      |             |                                      |
# |--------------------|-------------|-------------|-------------|--------------------------------------|
# |--------------------|-------------|-------------|-------------|--------------------------------------|

with lib;
let
  cfg = config.autoinstall;
  autoinstall = pkgs.writeScriptBin "autoinstall" (import ./ai.nix {
    hostname = cfg.hostname;
    rootDevice = cfg.rootDevice;
    windowsSize = cfg.windowsSize;
    matchMac = cfg.matchMac;
  });
in {
  options = {
    autoinstall = {
      enable = mkEnableOption {};
      hostname = mkOption {
        type = types.str;
        description = "the one that matters here -> modules/config-[hostname].nix"
      };
      rootDevice = mkOption {
        type = types.str;
        default = "/dev/nvme0n1";
        description = "install target device";
      };
      windowsSize = mkOption {
        type = types.int;
        default = 220000;
        description = "size of windows in MB (if 0, windows partitions will not be created)";
      };
      matchMac = mkOption {
        types = types.string;
        description = "MAC Address to match on (ex: '')";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ autoinstall ];
    boot.supportedFilesystems = [ "btrfs" ];
  };
}

