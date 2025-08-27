{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  hn = "zeph";
  poolname = "zephpool";
  bootpart = "zeph-boot";
  swappart = "zeph-swap";
  lukspart = "zeph-luksroot";
in
{
  imports = [
    ../../profiles/gui-cosmic.nix

    ../../profiles/addon-asus.nix
    ../../profiles/addon-devtools.nix
    ../../profiles/addon-gaming.nix
    ../../profiles/addon-laptop.nix

    ../../mixins/gfx-radeonsi.nix

    ../../mixins/pam-u2f.nix

    ../../mixins/android.nix
    ../../mixins/clamav.nix
    ../../mixins/ledger.nix
    ../../mixins/obs.nix # fucking Android can't _rotate it's webcam feed_
    ../../mixins/podman.nix
    ../../mixins/spotify.nix
    ../../mixins/syncthing.nix

    ./preservation.nix
    ./zrepl.nix # TODO: make this device specific

    inputs.determinate-main.nixosModules.default

    ./unfree.nix

    inputs.lanzaboote.nixosModules.lanzaboote

    inputs.nixos-hardware.nixosModules.common-hidpi
    inputs.nixos-hardware.nixosModules.asus-zephyrus-ga402

    inputs.ucodenix.nixosModules.ucodenix
  ];
  config = {
    nixpkgs.hostPlatform = "x86_64-linux";

    system.stateVersion = "23.11";

    networking.hostName = hn;

    nixcfg.common.hostColor = "magenta";
    nixcfg.common.skipMitigations = false;

    nixcfg.common.useZfs = true;
    nixcfg.common.useZfsUnstable = true;

    nix = {
      settings = {
        max-jobs = lib.mkForce 4;
      };
    };

    hardware.cpu.amd.ryzen-smu.enable = true;

    environment.systemPackages = with pkgs; [
      ryzenadj
      qemu
    ];

    zramSwap.enable = true;

    services.tailscale.useRoutingFeatures = "client";

    time.timeZone = lib.mkForce null; # we're on the move

    ## TODO: experimental
    services.dbus.implementation = "broker";
    ## END experimental

    # services.ucodenix = {
    #   enable = true;
    #   cpuModelId = "00A40F41";
    #   #cpuSerialNumber = "00A4-0F41-0000-0000-0000-0000"; # Replace with your processor's serial number
    # };

    services.zfs.autoScrub.pools = [ poolname ];
    fileSystems = {
      "/efi" = {
        fsType = "vfat";
        device = "/dev/nvme0n1p1";
      };
      "/boot" = {
        fsType = "vfat";
        device = "/dev/disk/by-partlabel/${bootpart}";
      };
      "/" = {
        fsType = "zfs";
        device = "${poolname}/root";
        neededForBoot = true;
      };
      "/nix" = {
        fsType = "zfs";
        device = "${poolname}/nix";
        neededForBoot = true;
      };
      "/home" = {
        fsType = "zfs";
        device = "${poolname}/home";
        neededForBoot = true;
      };
      "/persistent" = {
        fsType = "zfs";
        device = "${poolname}/persistent";
        neededForBoot = true;
      };

      # "/mnt/data/t5" = { fsType = "zfs"; device = "${poolname}/data/t5"; };
      "/mnt/games" = {
        fsType = "zfs";
        device = "${poolname}/games";
        neededForBoot = true;
      };

      "/mnt/media" = {
        fsType = "zfs";
        device = "${poolname}/media";
        neededForBoot = true;
      };

      "/efi/EFI/Linux" = {
        device = "/boot/EFI/Linux";
        options = [ "bind" ];
      };
      "/efi/EFI/nixos" = {
        device = "/boot/EFI/nixos";
        options = [ "bind" ];
      };
    };
    swapDevices = [ { device = "/dev/disk/by-partlabel/${swappart}"; } ];

    boot = {
      # zfs = {
      #   forceImportAll = true;
      #   extraPools = [ "zfsin" ];
      # };
      tmp = {
        useTmpfs = true;
      };
      bootspec.enable = true;
      lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";
        configurationLimit = 50;
      };
      loader = {
        efi.efiSysMountPoint = "/efi";
        systemd-boot = {
          enable = lib.mkForce (config.boot.lanzaboote.enable != true);
          configurationLimit = lib.mkForce 3;
        };
      };
      kernelModules = [
        "iwlwifi"
        "iwlmvm"
        "mac80211"
        "cfg80211"
        "ptp"
        "asus_wmi"
        "hid_asus"
      ];
      kernelParams = [
        # restrict hungry zfs arc:
        # "zfs.zfs_arc_max=${builtins.toString (1023 * 1024 * (1024 * 6))}"

        # ucode-nix: disable sig checking, though this machine doesn't have a new
        # bios, so it might not apply?
        # "microcode.amd_sha_check=off"
      ];
      initrd.availableKernelModules = [
        "xhci_pci"
        "xhci_hcd" # usb
        "nvme"
        "usb_storage"
        "sd_mod" # nvme / external usb storage
        "rtsx_pci_sdmmc" # sdcard
        "usbnet"
        "amdgpu"
        "spl" # try to fix systemd-udev-settle issue
        "zfs" # try to fix systemd-udev-settle issue
      ];
      initrd.luks.devices."nixos-luksroot" = {
        device = "/dev/disk/by-partlabel/${lukspart}";
        allowDiscards = true;
        crypttabExtraOpts = [ "fido2-device=auto" ];
      };
    };
  };
}
