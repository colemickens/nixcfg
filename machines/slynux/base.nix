{ pkgs, ... }:

let
  lib = pkgs.lib;
  nixosHardware = import ../../imports/nixos-hardware;
  hostname = "slynux";
in {
  imports = [
    #./power-management.nix

    ./nouveau.nix

    ../../modules/common.nix
    ../../modules/mixin-devenv.nix
    ../../modules/pkgs-common.nix
    ../../modules/pkgs-full.nix
    ../../modules/user-cole.nix

    ../../modules/profile-x86-only.nix

    ../../modules/profile-interactive.nix
    ../../modules/profile-gui.nix

    ../../modules/mixin-docker.nix
    #../../modules/hidden-gateway
    #../../modules/mixin-firecracker.nix
    #../../modules/mixin-intel-iris.nix
    ../../modules/mixin-libvirt.nix
    #../../modules/mixin-plex-mpv.nix
    ../../modules/mixin-mitmproxy.nix
    #../../modules/mixin-plex.nix
    ../../modules/mixin-sshd.nix
    #../../modules/mixin-ipfs.nix
    #../../modules/mixin-yubikey.nix

    ../../modules/loremipsum-media/rclone-cmd.nix
    ../../modules/mixin-spotifyd.nix

    ../../modules/mixin-v4l2loopback.nix
    ../../modules/hw-chromecast.nix

    #"${nixosHardware}/dell/xps/13-9370/default.nix"
  ];

  config = {
    # TODO move to devenv
    services.udev.packages = with pkgs; [ libsigrok ];

    system.stateVersion = "18.09"; # Did you read the comment?
    services.timesyncd.enable = true;

    time.timeZone = "US/Pacific";

    # ??
    services.tor = {
      enable = true;
      torsocks.enable = true;
      client.enable = true;
    };

    documentation.nixos.enable = false;

    fileSystems."/" = {
      device = "rpool/root";
      fsType = "zfs";
    };

    fileSystems."/nix" = {
      device = "rpool/nix";
      fsType = "zfs";
    };

    fileSystems."/var" = {
      device = "rpool/var";
      fsType = "zfs";
    };

    fileSystems."/home" = {
      device = "rpool/home";
      fsType = "zfs";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/7AC8-EF56";
      fsType = "vfat";
    };

    swapDevices = [ ];

    console.earlySetup = true; # hidpi + luks-open  # TODO : STILL NEEDED?
    console.font = "ter-v32n";
    console.packages = [ pkgs.terminus_font ];

    boot = {
      #zfs.requestEncryptionCredentials = true;
      kernelPackages = pkgs.linuxPackages_latest;
      initrd.availableKernelModules = [
        "xhci_pci"
        "nvme"
        "usb_storage"
        "sd_mod"
        "rtsx_pci_sdmmc"
        "intel_agp"
        "i915"
      ];
      kernelModules = [
        "xhci_pci"
        "nvme"
        "usb_storage"
        "sd_mod"
        "rtsx_pci_sdmmc"
        "intel_agp"
        "i915"
      ];
      kernelParams = [
        # HIGHLY IRRESPONSIBLE
        "noibrs"
        "noibpb"
        "nopti"
        "nospectre_v2"
        "nospectre_v1"
        "l1tf=off"
        "nospec_store_bypass_disable"
        "no_stf_barrier"
        "mds=off"
        "mitigations=off"

        #"i915.modeset=1"     # nixos-hw = missing
        #"i915.enable_guc=3"  # nixos-hw = missing
        #"i915.enable_gvt=0"  # nixos-hw = missing
        #"i915.enable_fbc=1"  # nixos-hw = 2
        #"i915.enable_psr=1"  # nixos-hw = missing?
        #"i915.fastboot=1"    # nixos-hw = missing?
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
        systemd-boot.configurationLimit = 2;
        efi.canTouchEfiVariables = true;
      };
    };
    networking = {
      hostId = "deadbeef";
      hostName = "slynux";
      firewall = {
        enable = true;
        allowedTCPPorts = [ 5900 ];
        #checkReversePath = "loose";
      };
      networkmanager.enable = true;
      networkmanager.wifi.backend = "iwd";
      wireguard.enable = true;
    };
    services.resolved.enable = false;

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
