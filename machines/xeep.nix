{ pkgs, ... }:

let
  lib = pkgs.lib;
  nixosHardware = builtins.fetchTarball
    "https://github.com/NixOS/nixos-hardware/archive/master.tar.gz";
  hostname = "xeep";
in
{
  imports = [
    ../modules/common.nix
    
    ../modules/profile-gui.nix
    ../modules/profile-sway.nix

    ../modules/mixin-docker.nix
    ../modules/mixin-sshd.nix
    ../modules/mixin-yubikey.nix
    ../modules/pkgs-full.nix

    ../modules/hw-magictrackpad2.nix

    "${builtins.toString nixosHardware}/dell/xps/13-9370/default.nix"
  ];

  config = {
    system.stateVersion = "18.09"; # Did you read the comment?
    time.timeZone = "America/Los_Angeles";
    services.timesyncd.enable = true;

    fileSystems = {
      "/" = {
        device = "/dev/vg/root";
        fsType = "ext4";
      };
      # xeep2
      #"/"    = { device = "/dev/mapper/nixos-btrfs"; fsType = "btrfs"; options = "subvol=root" };
      #"/nix" = { device = "/dev/mapper/nixos-btrfs"; fsType = "btrfs"; options = "subvol=nix" };
      #"/var" = { device = "/dev/mapper/nixos-btrfs"; fsType = "btrfs"; options = "subvol=nix" };
      "/boot" = {
        device = "/dev/disk/by-partlabel/nixos-boot";
        fsType = "vfat";
      };
    };
    swapDevices = [ ];
    boot = {
      earlyVconsoleSetup = true; # hidpi + luks-open
      kernelPackages = pkgs.linuxPackages_latest;
      initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" "intel_agp" "i915" ];
      kernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" "intel_agp" "i915" ];
      kernelParams = [
        "i915.modeset=1"     # nixos-hw = missing
        "i915.enable_guc=3"  # nixos-hw = missing
        #"i915.enable_gvt=0" # nixos-hw = missing
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
        #xeep2
        #{ 
        #  name = "nixos-btrfs";
        #  device = "/dev/disk/by-partlabel/nixos-luks";
        #  preLVM = true;
        #  allowDiscards = true;
        #}
      ];
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };
    };
    networking = {
      hostName = hostname;
      firewall.enable = true;
      firewall.allowedTCPPorts = [];
      networkmanager.enable = true;
    };
    services.resolved.enable = true;

    i18n.consolePackages = [ pkgs.terminus_font ]; # hidpi
    i18n.consoleFont = "ter-v32n"; # hidpi

    nix.maxJobs = 8;
    nix.nixPath = [
      "/etc/nixos"
      "nixpkgs=/home/cole/code/nixpkgs"
      "nixos-config=/home/cole/code/nixcfg/machines/${hostname}.nix"
    ];
    
    nixpkgs.config.allowUnfree = true; # for redistrib fw
    hardware = {
      bluetooth.enable = true;
      pulseaudio.package = pkgs.pulseaudioFull;
      enableRedistributableFirmware = true;
      cpu.intel.updateMicrocode = true;
      enableAllFirmware = true;
      u2f.enable = true;
    };
    services.fwupd.enable = true;

    powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
    powerManagement.enable = true;
    services.tlp.enable = true;
    services.upower.enable = true;
  };
}
