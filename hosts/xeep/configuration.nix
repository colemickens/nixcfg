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

    # ./services/aria2.nix
    ./services/revproxy.nix
    ./services/home-assistant
    # ./services/netboot-server.nix
    # ./services/samba.nix
    # ./services/rsntp.nix
    # ./services/rtsptoweb.nix
    ./services/snapserver.nix
    ./services/plex.nix
    ./services/unifi.nix
    

    # ../../mixins/gfx-intel.nix # TODO: nixosHardware?
    inputs.hardware.nixosModules.dell-xps-13-9370

    ./unfree.nix
    
    inputs.nix-netboot-server.nixosModules.nix-netboot-serve
  ];

  config = {
    networking.hostName = hn;
    system.stateVersion = "21.05";
    environment.systemPackages = with pkgs; [
      libsmbios # ? can't remember it
    ];
    
    # services.windmill = {
    #   enable = true;
    # };
      
    # services.paperless-ng = {
    #   enable = true;
    #   extraConfig = {
    #     PAPERLESS_AUTO_LOGIN_USERNAME = "admin";
    #   };
    # };

    hardware.bluetooth.enable = true;
    hardware.usbWwan.enable = true;
    hardware.cpu.intel.updateMicrocode = true;

    services.fwupd.enable = true;
    # services.fwupd.overrideEspMountPoint = "/boot";

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
        root = {
          name = "root";
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
