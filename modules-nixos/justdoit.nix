{ config, pkgs, lib, ... }:

with lib;
let
  cfg = config.kexec.justdoit;
  x = if cfg.nvme then "p" else "";
in {
  options = {
    kexec.justdoit = {
      rootDevice = mkOption {
        type = types.str;
        default = "/dev/sda";
        description = "the root block device that justdoit will nuke from orbit and force nixos onto";
      };
      bootSize = mkOption {
        type = types.int;
        default = 256;
        description = "size of /boot in mb";
      };
      bootType = mkOption {
        type = types.enum [ "ext4" "vfat" "zfs" ];
        default = "ext4";
      };
      swapSize = mkOption {
        type = types.int;
        default = 1024;
        description = "size of swap in mb";
      };
      poolName = mkOption {
        type = types.str;
        default = "tank";
        description = "zfs pool name";
      };
      luksEncrypt = mkOption {
        type = types.bool;
        default = false;
        description = "encrypt all of zfs and swap";
      };
      uefi = mkOption {
        type = types.bool;
        default = false;
        description = "create a uefi install";
      };
      nvme = mkOption {
        type = types.bool;
        default = false;
        description = "rootDevice is nvme";
      };
    };
  };
  config = let
    mkBootTable = {
      ext4 = "mkfs.ext4 $NIXOS_BOOT -L NIXOS_BOOT";
      vfat = "mkfs.vfat $NIXOS_BOOT -n NIXOS_BOOT";
      zfs = "";
    };
  in lib.mkIf true {
    system.build.justdoit = pkgs.writeScriptBin "justdoit" ''
      #!${pkgs.stdenv.shell}

      set -e
      false

      vgchange -a n

      wipefs -a ${cfg.rootDevice}
      dd if=/dev/zero of=${cfg.rootDevice} bs=512 count=10000
      sfdisk ${cfg.rootDevice} <<EOF
      label: gpt
      device: ${cfg.rootDevice}
      unit: sectors
      ${lib.optionalString (cfg.bootType != "zfs") "1 : size=${toString (2048 * cfg.bootSize)}, type=0FC63DAF-8483-4772-8E79-3D69D8477DE4"}
      ${lib.optionalString (! cfg.uefi) "4 : size=4096, type=21686148-6449-6E6F-744E-656564454649"}
      2 : size=${toString (2048 * cfg.swapSize)}, type=0657FD6D-A4AB-43C4-84E5-0933C84B4F4F
      3 : type=0FC63DAF-8483-4772-8E79-3D69D8477DE4
      EOF
      ${if cfg.luksEncrypt then ''
        cryptsetup luksFormat ${cfg.rootDevice}${x}2
        cryptsetup open --type luks ${cfg.rootDevice}${x}2 swap

        cryptsetup luksFormat ${cfg.rootDevice}${x}3
        cryptsetup open --type luks ${cfg.rootDevice}${x}3 root

        export ROOT_DEVICE=/dev/mapper/root
        export SWAP_DEVICE=/dev/mapper/swap
      '' else ''
        export ROOT_DEVICE=${cfg.rootDevice}${x}3
        export SWAP_DEVICE=${cfg.rootDevice}${x}2
      ''}
      ${lib.optionalString (cfg.bootType != "zfs") "export NIXOS_BOOT=${cfg.rootDevice}${x}1"}

      mkdir -p /mnt

      ${mkBootTable.${cfg.bootType}}
      mkswap $SWAP_DEVICE -L NIXOS_SWAP
      zpool create -o ashift=12 -o altroot=/mnt ${cfg.poolName} $ROOT_DEVICE
      zfs create -o mountpoint=legacy ${cfg.poolName}/root
      zfs create -o mountpoint=legacy ${cfg.poolName}/home
      zfs create -o mountpoint=legacy ${cfg.poolName}/nix

      swapon $SWAP_DEVICE
      mount -t zfs ${cfg.poolName}/root /mnt/
      mkdir /mnt/{home,nix,boot}
      mount -t zfs ${cfg.poolName}/home /mnt/home/
      mount -t zfs ${cfg.poolName}/nix /mnt/nix/
      ${lib.optionalString (cfg.bootType != "zfs") "mount $NIXOS_BOOT /mnt/boot/"}

      nixos-generate-config --root /mnt/

      hostId=$(echo $(head -c4 /dev/urandom | od -A none -t x4))
      #cp ./target-config.nix} /mnt/etc/nixos/configuration.nix

      cat > /mnt/etc/nixos/generated.nix <<EOF
      { ... }:
      {
        ${if cfg.uefi then ''
          boot.loader.grub.efiInstallAsRemovable = true;
          boot.loader.grub.efiSupport = true;
          boot.loader.grub.device = "nodev";
        '' else ''
          boot.loader.grub.device = "${cfg.rootDevice}";
        ''}
        networking.hostId = "$hostId"; # required for zfs use
      ${lib.optionalString cfg.luksEncrypt ''
        boot.initrd.luks.devices = [
          { name = "swap"; device = "${cfg.rootDevice}${x}2"; preLVM = true; }
          { name = "root"; device = "${cfg.rootDevice}${x}3"; preLVM = true; }
        ];
      ''}
      }
      EOF

      nixos-install

      umount /mnt/home /mnt/nix ${lib.optionalString (cfg.bootType != "zfs") "/mnt/boot"} /mnt
      zpool export ${cfg.poolName}
      swapoff $SWAP_DEVICE
    '';
    environment.systemPackages = [ config.system.build.justdoit ];
    boot.supportedFilesystems = [ "zfs" ];
  };
}
