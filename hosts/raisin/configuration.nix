{ config, pkgs, lib, inputs, ... }:
let
  hn = config.networking.hostName;
  # raisin bootloader = grub (signed-shim)
in
{
  imports = [
    ../../profiles/interactive.nix
    ../../profiles/laptop.nix

    ../../mixins/grub-signed-shim.nix

    # ../../mixins/android.nix
    ../../mixins/libvirtd.nix
    ../../mixins/sshd.nix
    ../../mixins/syncthing.nix
    ../../mixins/tailscale.nix
    ../../mixins/upower.nix
    ../../mixins/wpa-full.nix
    ../../mixins/zfs.nix

    ../../mixins/rclone-googledrive-mounts.nix

    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
  ];

  config = {
    system.stateVersion = "21.05";
    networking.hostName = "raisin";
    
    nixcfg.common.hostColor = "yellow";

    services.logind.extraConfig = ''
      HandlePowerKey=poweroff
      HandleLidSwitch=ignore
    '';

    fileSystems = {
      "/boot" = { fsType = "vfat"; device = "/dev/disk/by-partlabel/${hn}-boot"; neededForBoot = true; };
      "/" = { fsType = "zfs"; device = "${hn}pool/root"; neededForBoot = true; };
      "/nix" = { fsType = "zfs"; device = "${hn}pool/nix"; neededForBoot = true; };
      # "/backup" = { fsType = "zfs"; device = "${hn}pool/backup"; neededForBoot = true; };
      "/home" = { fsType = "zfs"; device = "${hn}pool/home"; neededForBoot = true; };
    };
    swapDevices = [{ device = "/dev/disk/by-partlabel/swap"; }];
    boot = {
      kernelModules = [ "iwlwifi" "ideapad_laptop" ];
      kernelParams = [
        "ideapad_laptop.allow_v4_dytc=1"
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
        preLVM = true;
        allowDiscards = true;
        
        keyFile = "/lukskey";
        fallbackToPassword = true; # doesn't work if keyfile is present, but not a valid luks key
      };
      initrd.secrets = {
        "/lukskey" = pkgs.writeText "lukskey" "test";
      };
    };
  };
}
