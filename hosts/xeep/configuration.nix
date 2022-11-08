{ config, pkgs, lib, inputs, ... }:
let
  hn = "xeep";
  static_ip = "192.168.1.10/16";
in
{
  imports = [
    ../../profiles/interactive.nix

    ../../mixins/grub-signed-shim.nix
    ../../mixins/libvirtd.nix
    ../../mixins/sshd.nix
    ../../mixins/syncthing.nix
    ../../mixins/tailscale.nix
    ../../mixins/upower.nix
    ../../mixins/zfs.nix

    ../../mixins/rclone-googledrive-mounts.nix

    ./services/revproxy.nix
    ./services/home-assistant
    ./services/plex.nix
    ./services/unifi.nix
    

    # ../../mixins/gfx-intel.nix # TODO: nixosHardware?
    inputs.nixos-hardware.nixosModules.dell-xps-13-9370

    ./unfree.nix
    
    inputs.nix-netboot-server.nixosModules.nix-netboot-serve
  ];

  config = {
    networking.hostName = hn;
    system.stateVersion = "21.05";
    environment.systemPackages = with pkgs; [
      libsmbios # ? can't remember it
    ];
    
    nixcfg.common.hostColor = "orange";
    nixcfg.common.useXeepTimeserver = false;
    
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
      loader.efi.efiSysMountPoint = "/boot";
      kernelModules = config.boot.initrd.availableKernelModules;
      kernelParams = [ "zfs.zfs_arc_max=${builtins.toString (1024 * 1024 * 2048)}" ];
      initrd.luks.devices = {
        "nixos-luksroot" = {
          device = "/dev/disk/by-partlabel/newluks";
          preLVM = true;
          allowDiscards = true;

          keyFileSize = 4096;
          keyFile = "/dev/disk/by-id/mmc-EB1QT_0xa5f25355";
          fallbackToPassword = true;
        };
      };
    };

    fileSystems = {
      "/boot" = { fsType = "vfat"; device = "/dev/disk/by-partlabel/newboot"; };
      "/" = { fsType = "zfs"; device = "tank2/root"; };
      "/home" = { fsType = "zfs"; device = "tank2/home"; };
      "/backup" = { fsType = "zfs"; device = "tank2/backup"; };
      "/nix" = { fsType = "zfs"; device = "tank2/nix2"; };
    };
    swapDevices = [ ];
  };
}
