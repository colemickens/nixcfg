{ config, pkgs, lib, inputs, modulesPath, ... }:

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
      toplevel = mkOption {
        type = types.str;
        description = "the toplevel to install";
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
        default = true;
        description = "create a uefi install";
      };
      nvme = mkOption {
        type = types.bool;
        default = false;
        description = "rootDevice is nvme";
      };
    };
  };
  
  imports = [
    "${modulesPath}/installer/netboot/netboot-minimal.nix"
  ];
  
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

      nix-store --store /mnt \
        --option 'extra-binary-caches' 'https://cache.nixos.org https://colemickens.cachix.org https://nixpkgs-wayland.cachix.org https://arm.cachix.org https://thefloweringash-armv7.cachix.org' \
        --option 'trusted-public-keys' 'cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= colemickens.cachix.org-1:bNrJ6FfMREB4bd4BOjEN85Niu8VcPdQe4F4KxVsb/I4= nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA= arm.cachix.org-1:5BZ2kjoL1q6nWhlnrbAl+G7ThY7+HaBRD9PZzqZkbnM= thefloweringash-armv7.cachix.org-1:v+5yzBD2odFKeXbmC+OPWVqx4WVoIVO6UXgnSAWFtso=' \
        -r "${builtins.unsafeDiscardStringContext cfg.toplevel}"

      nixos-install "${builtins.unsafeDiscardStringContext cfg.toplevel}"
      
      umount /mnt/home /mnt/nix ${lib.optionalString (cfg.bootType != "zfs") "/mnt/boot"} /mnt
      zpool export ${cfg.poolName}
      swapoff $SWAP_DEVICE
    '';
    environment.systemPackages = [ config.system.build.justdoit ];
    boot.supportedFilesystems = [ "zfs" ];
  };
}
