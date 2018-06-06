{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # workaround Dell/NVME issue with s2idle
  # see: 
  #  - https://www.reddit.com/r/Dell/comments/8b6eci/xp_13_9370_battery_drain_while_suspended/
  #  - https://bugzilla.kernel.org/show_bug.cgi?id=199057
  #  - https://bugzilla.kernel.org/show_bug.cgi?id=196907
  boot.kernelParams = [ "mem_sleep_default=deep" ];

  boot.initrd.luks.devices = [
    { 
      name = "root";
      device = "/dev/disk/by-partlabel/xeep-luks";
      preLVM = true;
      allowDiscards = true; # TODO
    }
  ];

  fileSystems."/" = {
    device = "/dev/vg/root";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-partlabel/xeep-boot";
    fsType = "vfat";
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  swapDevices = [ ];

  nix.maxJobs = lib.mkDefault 8;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
