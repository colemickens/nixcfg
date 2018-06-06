{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ata_piix" "usbhid" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/dc46f531-a364-4f55-a0d3-7b2441ed63a2";
    fsType = "ext4";
    #allowDiscards = true; # TODO
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/03F7-8754";
    fsType = "vfat";
  };

  fileSystems."/media/data" = {
    device = "/dev/sdc";
    fsType = "btrfs";
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  swapDevices = [ ];

  nix.maxJobs = lib.mkDefault 4;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
