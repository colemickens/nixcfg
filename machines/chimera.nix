{ config, lib, pkgs, ... }:

let
  nixosHardware = builtins.fetchTarball
    "https://github.com/NixOS/nixos-hardware/archive/master.tar.gz";
  hostname = "chimera";
in
{
  imports = [
    ../modules/common.nix
    
    ../modules/mixin-docker.nix
    ../modules/mixin-libvirt.nix
    ../modules/mixin-plex.nix
    ../modules/mixin-samba.nix
    ../modules/mixin-sshd.nix
    ../modules/mixin-transmission.nix
    ../modules/mixin-unifi.nix

    "${builtins.toString nixosHardware}/common/cpu/intel"
  ];

  config = {
    system.stateVersion = "18.09"; # Did you read the comment?
    time.timeZone = "America/Los_Angeles";
    services.timesyncd.enable = true;

    fileSystems = {
      "/" = {
        device = "/dev/disk/by-uuid/dc46f531-a364-4f55-a0d3-7b2441ed63a2";
        fsType = "ext4";
      };
      "/boot" = {
        device = "/dev/disk/by-uuid/03F7-8754";
        fsType = "vfat";
      };
      "/media/data" = {
        device = "/dev/sdc";
        fsType = "btrfs";
      };
    };
    swapDevices = [];
    boot = {
      kernelPackages = pkgs.linuxPackages_latest;
      
      initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ata_piix" "usbhid" "usb_storage" "sd_mod" "intel_agp" "i915" ];
      kernelModules = [ "xhci_pci" "ehci_pci" "ata_piix" "usbhid" "usb_storage" "sd_mod" "intel_agp" "i915" ];
      supportedFilesystems = [ "btrfs" ];
      initrd.supportedFilesystems = [ "btrfs" ];
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };
    };
    networking = {
      hostId = "2aaf4ef3";
      hostName = hostname;
      firewall.enable = true;
      firewall.allowedTCPPorts = [];
      networkmanager.enable = true;
    };
    services.resolved.enable = true;
    
    nix.maxJobs = 4;
    nix.nixPath = [
      "/etc/nixos"
      "nixpkgs=/home/cole/code/nixpkgs"
      "nixos-config=/home/cole/code/nixcfg/machines/${hostname}.nix"
    ];

    nixpkgs.config.allowUnfree = true; # for redistrib fw
    hardware = {
      bluetooth.enable = false;
      pulseaudio.package = pkgs.pulseaudioFull;
      enableRedistributableFirmware = true;
      cpu.intel.updateMicrocode = true;
      enableAllFirmware = true;
      u2f.enable = true;
    };
    services.fwupd.enable = true;

    powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
    powerManagement.enable = false;
    services.tlp.enable = false;
    services.upower.enable = true;
  };
}

