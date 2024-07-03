# Example to create a bios compatible gpt partition
{ lib, ... }:

let
  # persist_nix = true;
  persist_nix = false;
in
{
  disko.devices = {
    # uncommenting this breaks nixos-anywhere deployment
    disk = {
      disk1 = {
        device = lib.mkDefault "/dev/disk/by-path/pci-0000:06:00.0-scsi-0:0:0:0";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              name = "boot";
              size = "1M";
              type = "EF02";
            };
            esp = {
              name = "ESP";
              size = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              name = "root";
              size = "100%";
              content = {
                type = "lvm_pv";
                vg = "pool";
              };
            };
          };
        };
      };
      disk2 = {
        device = lib.mkDefault "/dev/disk/by-path/pci-0000:06:00.0-scsi-0:0:0:1";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            home = {
              name = "home";
              size = "24G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/home";
              };
            };
            nix = {
              name = "nix";
              size = "74G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/nix";
              };
            };
          };
        };
      };
    };
    lvm_vg = {
      pool = {
        type = "lvm_vg";
        lvs = {
          root = {
            size = "100%FREE";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              mountOptions = [
                "defaults"
              ];
            };
          };
        };
      };
    };
  };
}
