{ config, pkgs, lib, inputs, ... }:

let
  hn = "zeph";
in
{
  imports = [
    ../../profiles/gui-sway.nix
    ../../profiles/addon-asus.nix
    ../../profiles/addon-dev.nix
    ../../profiles/addon-laptop.nix

    ../../profiles/addon-nomad.nix

    ../../mixins/gfx-radeonsi.nix
    ../../mixins/gfx-debug.nix

    # ../../mixins/android.nix
    # ../../mixins/easyeffects.nix
    ../../mixins/hidpi.nix
    ../../mixins/ledger.nix
    ../../mixins/libvirt.nix
    ../../mixins/libvirtd.nix
    ../../mixins/syncthing.nix
    ../../mixins/zfs.nix

    # ../../mixins/oavm-risky.nix

    # ./experimental.nix
    ./unfree.nix

    ../../modules/other-arch-vm.nix

    inputs.lanzaboote.nixosModules.lanzaboote

    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
  ];
  config = {
    nixpkgs.hostPlatform.system = "x86_64-linux";
    system.stateVersion = "21.05";

    networking.hostName = hn;
    nixcfg.common.hostColor = "purple";
    nixcfg.common.skipMitigations = true;
    nixcfg.common.defaultKernel = true;
    nixcfg.common.addLegacyboot = false;

    services.tailscale.useRoutingFeatures = "client";

    time.timeZone = lib.mkForce null; # we're on the move

    fileSystems = {
      "/efi" = { fsType = "vfat"; device = "/dev/nvme0n1p1"; neededForBoot = true; };
      "/boot" = { fsType = "vfat"; device = "/dev/disk/by-partlabel/${hn}-boot"; neededForBoot = true; };
      "/" = { fsType = "zfs"; device = "${hn}pool/root"; neededForBoot = true; };
      "/nix" = { fsType = "zfs"; device = "${hn}pool/nix"; neededForBoot = true; };
      "/home" = { fsType = "zfs"; device = "${hn}pool/home"; neededForBoot = true; };

      "/mnt/data/t5" = { fsType = "zfs"; device = "${hn}pool/data/t5"; };

      "/efi/EFI/Linux" = { device = "/boot/EFI/Linux"; options = [ "bind" ]; };
      "/efi/EFI/nixos" = { device = "/boot/EFI/nixos"; options = [ "bind" ]; };
    };
    swapDevices = [{ device = "/dev/disk/by-partlabel/${hn}-swap"; }];

    # TODO: re-enable if/when I'm actually going to test it
    # specialisation."sysd-netboot" = lib.mkIf (config.boot.initrd.systemd.enable) {
    #   inheritParentConfig = true;
    #   configuration = {
    #     boot.initrd.systemd.network.enable = true;
    #   };
    # };

    home-manager.users.cole = { pkgs, config, ... }@hm: {
      wayland.windowManager.sway.config = {
        startup = [
          { command = "${pkgs.asusctl}/bin/rog-control-center"; }
        ];
        keybindings = {
          "XF86Launch1" = "exec ${pkgs.asusctl}/bin/rog-control-center";
        };
      };
    };

    networking.wireless.iwd.settings = {
      General = {
        AddressRandomization = "disabled";
      };
    };

    boot = {
      bootspec.enable = true;
      lanzaboote = {
        enable = true;
        pkiBundle = "/etc/secureboot";
        configurationLimit = 4;
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
      ];
      extraModprobeConfig = ''
        options iwlwifi power_save=0
        options iwlmvm power_scheme=1
      '';
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
        "intel_agp"
        "usbnet"
      ];
      initrd.luks.devices."nixos-luksroot" = {
        device = "/dev/disk/by-partlabel/${hn}-luksroot";
        allowDiscards = true;
        crypttabExtraOpts = [ "fido2-device=auto" ];
      };
    };
  };
}
