{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" "intel_agp" "i915" ];
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];

  # workaround Dell/NVME issue with s2idle
  # see: 
  #  - https://www.reddit.com/r/Dell/comments/8b6eci/xp_13_9370_battery_drain_while_suspended/
  #  - https://bugzilla.kernel.org/show_bug.cgi?id=199057
  #  - https://bugzilla.kernel.org/show_bug.cgi?id=196907
    # TODO: see if this is still needed with the XPS 13. A BIOS update has changed things somewhat
    #kernelParams = [ "mem_sleep_default=deep" ];

    extraModprobeConfig = ''
      # intel graphics
      options i915 modeset=1
      options i915 enable_guc=3
      options i915 enable_gvt=1
      options i915 enable_fbc=1
      options i915 enable_psr=1
      options i915 fastboot=1
    '';
      #options i915 lvds_downclock=1 #??
      #options i915 powersave=1 #??
    initrd.luks.devices = [
      { 
        name = "root";
        device = "/dev/disk/by-partlabel/xeep-luks";
        preLVM = true;
        allowDiscards = true; # TODO
      }
    ];
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  fileSystems."/" = {
    device = "/dev/vg/root";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-partlabel/xeep-boot";
    fsType = "vfat";
  };

  swapDevices = [ ];

  nix.maxJobs = lib.mkDefault 8;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
