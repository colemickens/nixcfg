{ config, lib, pkgs, ... }:

let
in {
  imports = [
    ./common
    ./mixin-plex.nix
    ./mixin-samba.nix
    ./mixin-transmission.nix
    ./mixin-unifi.nix
    ./mixin-wireguard-server.nix
  ];

  userOptions.cole = { tmuxColor="cyan"; bashColor="1;36"; };

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
  
  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ata_piix" "usbhid" "usb_storage" "sd_mod" ];
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "kvm-intel" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    extraModulePackages = [];
  };

  swapDevices = [];

  system.stateVersion = "18.09"; # Did you read the comment?
  nix.maxJobs = 4;
  networking = {
    hostName = "chimera";
    networkmanager.enable = true;
  };

  i18n.consoleFont = "Lat2-Terminus16";
  time.timeZone = "America/Los_Angeles";

  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
    enableAllFirmware = true;
    u2f.enable = true;
  };

  powerManagement.enable = false;
  services.tlp.enable = false;
}

