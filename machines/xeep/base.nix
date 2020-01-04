{ pkgs, ... }:

let
  lib = pkgs.lib;
  nixosHardware = import ../../pkgs/nixos-hardware;
  hostname = "xeep";
in
{
  imports = [
    ./power-management.nix

    ../../modules/common.nix
    ../../modules/mixin-devenv.nix
    ../../modules/mixin-intel-iris.nix
    ../../modules/pkgs-common.nix
    ../../modules/pkgs-full.nix
    ../../modules/user-cole.nix

    ../../modules/profile-interactive.nix
    ../../modules/profile-gui.nix

    #../../modules/mixin-docker.nix
    #../../modules/mixin-firecracker.nix
    #../../modules/mixin-libvirt.nix
    #../../modules/mixin-home-assistant.nix
    ../../modules/mixin-mitmproxy.nix
    ../../modules/mixin-sshd.nix
    #../../modules/mixin-ipfs.nix
    ../../modules/mixin-unifi.nix
    #../../modules/mixin-yubikey.nix

    ../../modules/loremipsum-media/rclone-cmd.nix
    ../../modules/mixin-spotifyd.nix

    ../../modules/mixin-v4l2loopback.nix
    ../../modules/hw-chromecast.nix

    "${nixosHardware}/dell/xps/13-9370/default.nix"
  ];

  config = {
    system.stateVersion = "18.09"; # Did you read the comment?
    services.timesyncd.enable = true;

    documentation.nixos.enable = false;

    # extract?
    services.ratbagd.enable = true;

    environment.systemPackages = with pkgs; [ 
      libratbag piper
      undervolt
      (pkgs.writeScriptBin "dell-fix-power" ''
        #!/usr/bin/env bash
        oldval="$(sudo ${pkgs.msr-tools}/bin/rdmsr 0x1FC)"
        newval="$(( 0xFFFFFFFE & 0x$oldval ))"
        sudo ${pkgs.msr-tools}/bin/wrmsr -a 0x1FC "$val"
      '')
    ];

    #fileSystems = {
    #  "/" =     { fsType = "ext4"; device = "/dev/vg/root"; };
    #  "/boot" = { fsType = "vfat"; device = "/dev/disk/by-partlabel/nixos-boot"; };
    #};
    fileSystems = {
      "/" =     { fsType = "zfs";  device = "rpool2/nixos"; };
      "/boot" = { fsType = "vfat"; device = "/dev/disk/by-partlabel/nixos-boot"; };
      "/home" = { fsType = "zfs";  device = "rpool2/home"; };
    };
    swapDevices = [ ];

    console.earlySetup = true; # hidpi + luks-open  # TODO : STILL NEEDED?
    console.font = "ter-v32n";
    console.packages = [ pkgs.terminus_font ];

    boot = {
      zfs.requestEncryptionCredentials = true;
      kernelPackages = pkgs.linuxPackages_latest;
      initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" "intel_agp" "i915" ];
      kernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" "intel_agp" "i915" ];
      kernelParams = [
        # HIGHLY IRRESPONSIBLE
        "noibrs" "noibpb" "nopti" "nospectre_v2"
        "nospectre_v1" "l1tf=off" "nospec_store_bypass_disable"
        "no_stf_barrier" "mds=off" "mitigations=off"

        "i915.modeset=1"     # nixos-hw = missing
        "i915.enable_guc=3"  # nixos-hw = missing
        "i915.enable_gvt=0"  # nixos-hw = missing
        "i915.enable_fbc=1"  # nixos-hw = 2
        "i915.enable_psr=1"  # nixos-hw = missing?
        "i915.fastboot=1"    # nixos-hw = missing?
      ];
      supportedFilesystems = [ "btrfs" "zfs" ];
      initrd.supportedFilesystems = [ "btrfs" "zfs" ];
      #initrd.luks.devices = [
      #  {
      #    name = "root";
      #    device = "/dev/disk/by-partlabel/nixos-luks";
      #    preLVM = true;
      #    allowDiscards = true;
      #  }
      #];
      loader = {
        timeout = 1;
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };
    };
    networking = {
      hostId = "ef66d560";
      hostName = hostname;
      firewall.enable = true;
      networkmanager.enable = true;
      networkmanager.wifi.backend = "iwd";
    };
    services.resolved.enable = true;

    nix.maxJobs = 8;
    nixpkgs.config.allowUnfree = true;
    hardware = {
      bluetooth.enable = true;
      pulseaudio.package = pkgs.pulseaudioFull;
      enableRedistributableFirmware = true;
      cpu.intel.updateMicrocode = true;
      u2f.enable = true;
    };
    services.fwupd.enable = true;
  };
}
