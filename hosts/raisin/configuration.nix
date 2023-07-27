{ config, pkgs, lib, inputs, ... }:
let
  hn = "raisin";
  pool = "raisin2pool";
  static_ip = "192.168.70.60/16";
in
{
  imports = [
    ./unfree.nix

    ../../profiles/interactive.nix
    ../../profiles/addon-laptop.nix

    ../../mixins/iwd-networks.nix
    ../../mixins/plex.nix
    ../../mixins/rclone-googledrive-mounts.nix
    ../../mixins/syncthing.nix
    ../../mixins/zfs.nix

    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
  ];

  config = {
    nixpkgs.hostPlatform.system = "x86_64-linux";
    system.stateVersion = "21.05";

    networking.hostName = hn;
    nixcfg.common.hostColor = "green";

    services.tailscale.useRoutingFeatures = "server";

    services.logind.extraConfig = ''
      HandlePowerKey=ignore
      HandleLidSwitch=ignore
    '';
    
    systemd.network = {
      enable = true;
      networks."15-eth0-static-ip" = {
        matchConfig.Path = "pci-0000:03:00.3-usb-0:1:1.0";
        addresses = [{ addressConfig = { Address = static_ip; }; }];
        networkConfig = {
          Gateway = "192.168.1.1";
          DHCP = "no";
        };
      };
    };

    fileSystems = {
      "/" = { fsType = "zfs"; device = "${pool}/root"; neededForBoot = true; };
      "/home" = { fsType = "zfs"; device = "${pool}/home"; neededForBoot = true; };
      "/nix" = { fsType = "zfs"; device = "${pool}/nix"; neededForBoot = true; };
      "/boot" = { fsType = "vfat"; device = "/dev/disk/by-partlabel/raisin2-boot"; neededForBoot = true; };
    };
    swapDevices = [{ device = "/dev/disk/by-partlabel/raisin2-swap"; }];

    boot = {
      kernelModules = [ "iwlwifi" "ideapad_laptop" ];
      kernelParams = [
        "ideapad_laptop.allow_v4_dytc=1"
        # "zfs.zfs_arc_max=${builtins.toString (1024 * 1024 * 1024 * 8)}"
      ];
      # kernelParams = [ "zfs.zfs_arc_max=${builtins.toString (1024 * 1024 * 2048)}" ];
      initrd.availableKernelModules = [
        "xhci_pci"
        "xhci_hcd" # usb
        "nvme"
        "usb_storage"
        "sd_mod" # nvme / external usb storage
        "rtsx_pci_sdmmc" # sdcard
        "intel_agp"
        "usbnet"
      ];
      initrd.luks.devices."nixos-luksroot" = {
        device = "/dev/disk/by-partlabel/${hn}-luksroot";
        allowDiscards = true;
        keyFile = "/lukskey";
      };
      initrd.secrets = {
        "/lukskey" = pkgs.writeText "lukskey" "test";
      };
    };
  };
}
