{ pkgs, inputs, ... }:

let
  hn = "raisin";
  poolname = "raisin2pool";
  bootpart = "raisin2-boot";
  swappart = "raisin2-swap";
  lukspart = "raisin-luksroot";
in
{
  imports = [
    ./unfree.nix

    ../../profiles/interactive.nix
    ../../profiles/addon-laptop.nix

    ../../mixins/syncthing.nix

    ./zrepl.nix

    inputs.determinate.nixosModules.default

    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
  ];

  config = {
    nixpkgs.hostPlatform.system = "x86_64-linux";
    system.stateVersion = "23.11";

    networking.hostName = hn;
    nixcfg.common.hostColor = "green";
    nixcfg.common.wifiWorkaround = true;

    zramSwap.enable = true;

    services.tailscale.useRoutingFeatures = "server";

    services.zfs.autoScrub.pools = [ poolname ];

    services.logind.settings.Login = {
      HandlePowerKey = "ignore";
      HandleLidSwitch = "ignore";
    };

    systemd.network.enable = true;

    fileSystems = {
      "/" = {
        fsType = "zfs";
        device = "${poolname}/root";
        neededForBoot = true;
      };
      "/home" = {
        fsType = "zfs";
        device = "${poolname}/home";
        neededForBoot = true;
      };
      "/nix" = {
        fsType = "zfs";
        device = "${poolname}/nix";
        neededForBoot = true;
      };
      "/boot" = {
        fsType = "vfat";
        device = "/dev/disk/by-partlabel/${bootpart}";
        neededForBoot = true;
      };
    };
    swapDevices = [ { device = "/dev/disk/by-partlabel/${swappart}"; } ];

    boot = {
      kernelModules = [
        "iwlwifi"
        "ideapad_laptop"
        "tp_smapi"
      ];
      kernelParams = [
        "ideapad_laptop.allow_v4_dytc=1"
        # "zfs.zfs_arc_max=${builtins.toString (1024 * 1024 * 1024 * 8)}"
      ];
      # kernelParams = [ "zfs.zfs_arc_max=${builtins.toString (1024 * 1024 * 2048)}" ];
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
        device = "/dev/disk/by-partlabel/${lukspart}";
        allowDiscards = true;
        keyFile = "/lukskey";
      };
      initrd.secrets = {
        "/lukskey" = pkgs.writeText "lukskey" "test";
      };
    };
  };
}
