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
    # NO! look in configuration.nix for the actual gui/profile config

    ../../profiles/addon-asus.nix
    ../../profiles/addon-devtools.nix
    ../../profiles/addon-gaming.nix
    ../../profiles/addon-laptop.nix

    ../../mixins/gfx-radeonsi.nix
    ../../mixins/gfx-debug.nix

    ../../mixins/android.nix
    ../../mixins/clamav.nix
    ../../mixins/ledger.nix
    ../../mixins/libvirt.nix
    ../../mixins/libvirtd.nix
    ../../mixins/monero.nix
    ../../mixins/podman.nix
    ../../mixins/spotify.nix
    ../../mixins/syncthing.nix
    ../../mixins/trezor.nix

    ./zrepl.nix # TODO: make this device specific

    # ../../mixins/oavm-risky.nix

    # ./experimental.nix
    ./unfree.nix

    inputs.lanzaboote.nixosModules.lanzaboote

    inputs.nixos-hardware.nixosModules.common-hidpi
    inputs.nixos-hardware.nixosModules.asus-zephyrus-ga402
  ];
  config = {
    # nixpkgs.hostPlatform.system = "x86_64-linux";
    nixpkgs.hostPlatform = "x86_64-linux";

    # TODO: why does this cause inf recursion with mangohud?
    # nixpkgs.buildPlatform.system = "x86_64-linux";
    system.stateVersion = "23.11";

    # TODO: evaluate if this is worth the cost in closure size
    # https://linus.schreibt.jetzt/posts/include-build-dependencies.html
    # TODO: re-evaluate, too much to shove through cachix, and slow internetzzz
    # system.includeBuildDependencies = true;

    networking.hostName = hn;
    # nixcfg.common.hostColor = "#c17ecc"; # tango magenta
    nixcfg.common.hostColor = "magenta";
    nixcfg.common.skipMitigations = false;

    # zfs schenanigans
    nixcfg.common.useZfs = true;
    nixcfg.common.useZfsUnstable = true;

    nix = {
      settings = {
        max-jobs = lib.mkForce 4;
      };
    };

    environment.systemPackages = with pkgs; [ esphome ];

    services.tailscale.useRoutingFeatures = "client";

    time.timeZone = lib.mkForce null; # we're on the move

    ## TODO: experimental
    services.dbus.implementation = "broker";
    ## END experimental

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

      # "/mnt/data/t5" = { fsType = "zfs"; device = "${poolname}/data/t5"; };
      "/mnt/games" = {
        fsType = "zfs";
        device = "${poolname}/games";
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

    home-manager.users.cole =
      { pkgs, config, ... }@hm:
      {
        wayland.windowManager.sway.config = {
          keybindings = {
            "XF86AudioRaiseVolume" = "exec ${pkgs.pulsemixer}/bin/pulsemixer --change-volume +2";
            "XF86AudioLowerVolume" = "exec ${pkgs.pulsemixer}/bin/pulsemixer --change-volume -2";
            "XF86AudioMicMute" = "exec ${pkgs.pulsemixer}/bin/pulsemixer --toggle-mute";
            "XF86Launch1" = "exec ${pkgs.asusctl}/bin/rog-control-center";
            "Mod4+XF86Launch1" = "exec ${pkgs.pavucontrol}/bin/pavucontrol";
          };
        };
      };

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
        pkiBundle = "/etc/secureboot";
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
      # extraModprobeConfig = ''
      #   options iwlwifi power_save=0
      #   options iwlmvm power_scheme=1
      # '';
      kernelParams = [
        # "zfs.zfs_arc_max=${builtins.toString (1023 * 1024 * (1024 * 6))}"
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
