{ config, pkgs, lib, inputs, ... }:
let
  hn = "xeep";
  static_ip = "192.168.1.10/16";
in
{
  imports = [
    ../../profiles/interactive.nix
    ../../profiles/addon-laptop.nix

    ../../mixins/iwd-networks.nix
    # ../../mixins/plex.nix
    # ../../mixins/rclone-googledrive-mounts.nix
    ../../mixins/syncthing.nix
    ../../mixins/unifi.nix
    ../../mixins/zfs.nix
    # ./services/revproxy.nix
    # ./services/home-assistant

    # ../../mixins/gfx-intel.nix # TODO: nixosHardware?
    inputs.nixos-hardware.nixosModules.dell-xps-13-9370

    ./unfree.nix

    inputs.nix-netboot-server.nixosModules.nix-netboot-serve
  ];

  config = {
    nixpkgs.hostPlatform.system = "x86_64-linux";

    networking.hostName = hn;
    system.stateVersion = "21.05";
    environment.systemPackages = with pkgs; [
      libsmbios # ? can't remember it
    ];

    nixcfg.common.hostColor = "yellow";
    nixcfg.common.useXeepTimeserver = false;

    services.tailscale.useRoutingFeatures = "server";

    systemd.network = {
      enable = true;
      networks."15-eth0-static-ip" = {
        matchConfig.Driver = "r8152";
        addresses = [{ addressConfig = { Address = static_ip; }; }];
        networkConfig = {
          Gateway = "192.168.1.1";
          DNS = "192.168.1.1";
          DHCP = "ipv6";
        };
      };
    };

    boot = {
      loader.systemd-boot.enable = true;
      loader.efi.efiSysMountPoint = "/boot";
      initrd.availableKernelModules = [
        "xhci_pci"
        "xhci_hcd" # usb
        "nvme"
        "usb_storage"
        "sd_mod" # nvme / external usb storage
        "rtsx_pci_sdmmc" # sdcard
        "intel_agp"
        "i915" # intel integrated graphics
        "usbnet"
        "r8152" # usb ethernet adapter
        "msr"
      ];
      kernelModules = config.boot.initrd.availableKernelModules;
      kernelParams = [ "zfs.zfs_arc_max=${builtins.toString (1024 * 1024 * 2048)}" ];
      initrd.luks.devices = {
        "nixos-luksroot" = {
          device = "/dev/disk/by-partlabel/${hn}-luks";
          preLVM = true;
          allowDiscards = true;

          keyFileSize = 4096;
          keyFile = "/dev/disk/by-id/mmc-EB1QT_0xa5f25355";
          fallbackToPassword = true;
        };
      };
    };

    fileSystems = let zpool = "${hn}pool"; in {
      "/" = { fsType = "zfs"; device = "${zpool}/root"; };
      "/nix" = { fsType = "zfs"; device = "${zpool}/nix"; };
      "/home" = { fsType = "zfs"; device = "${zpool}/home"; };
      "/boot" = { fsType = "vfat"; device = "/dev/disk/by-partlabel/${hn}-boot"; };
    };
    swapDevices = [ ];
  };
}
