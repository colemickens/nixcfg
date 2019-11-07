{ pkgs, ... }:

let
  lib = pkgs.lib;
  nixosHardware = import ../imports/misc/nixos-hardware;
  hostname = "xeep";
in
{
  imports = [
    ../modules/common.nix
    ../modules/pkgs-common.nix
    ../modules/pkgs-full.nix
    ../modules/user-cole.nix

    ../modules/profile-interactive.nix
    ../modules/profile-gui.nix

    #../modules/mixin-docker.nix
    #../modules/mixin-firecracker.nix
    #../modules/mixin-libvirt.nix
    #../modules/mixin-sshd.nix
    #../modules/mixin-ipfs.nix
    #../modules/mixin-yubikey.nix

    ../modules/loremipsum-media/rclone-cmd.nix
    ../modules/mixin-spotifyd.nix

    ../modules/mixin-v4l2loopback.nix
    ../modules/hw-chromecast.nix

    "${nixosHardware.src}/dell/xps/13-9370/default.nix"
  ];

  config = {
    system.stateVersion = "18.09"; # Did you read the comment?
    services.timesyncd.enable = true;

    documentation.nixos.enable = false;

    environment.systemPackages = with pkgs; [ msr-tools ]; # dell powerthrottling workaround script

    fileSystems = {
      "/" =     { fsType = "ext4"; device = "/dev/vg/root"; };
      "/boot" = { fsType = "vfat"; device = "/dev/disk/by-partlabel/nixos-boot"; };
    };
    swapDevices = [ ];
    boot = {
      earlyVconsoleSetup = true; # hidpi + luks-open
      kernelPackages = pkgs.linuxPackages_testing;
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
      supportedFilesystems = [ "btrfs" ];
      initrd.supportedFilesystems = [ "btrfs" ];
      initrd.luks.devices = [
        {
          name = "root";
          device = "/dev/disk/by-partlabel/nixos-luks";
          preLVM = true;
          allowDiscards = true;
        }
      ];
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };
    };
    networking = {
      hostId = "ef66d560";
      hostName = hostname;
      firewall.enable = false;
      networkmanager.enable = true;
      networkmanager.wifi.backend = "iwd";
    };
    services.resolved.enable = false;

    i18n.consolePackages = [ pkgs.terminus_font ]; # hidpi
    i18n.consoleFont = "ter-v32n"; # hidpi

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

    powerManagement.enable = true;
    services.tlp.enable = true;
    services.tlp.extraConfig = ''
      #START_CHARGE_THRESH_BAT0=75
      #STOP_CHARGE_THRESH_BAT0=80
      CPU_SCALING_GOVERNOR_ON_BAT=powersave
      CPU_SCALING_GOVERNOR_ON_AC=performance
      ENERGY_PERF_POLICY_ON_BAT=powersave
    '';
    services.upower.enable = true;
  };
}
