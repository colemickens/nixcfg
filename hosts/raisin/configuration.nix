{ config, pkgs, lib, inputs, ... }:
let
  hn = "raisin";
  poolname = "raisin2pool";
  bootpart = "raisin2-boot";
  swappart = "raisin2-swap";
  lukspart = "raisin-luksroot";
  # ugh, bad idea, zaks network doesn't have this probably:
  # static_ip = "192.168.70.60/16";
in
{
  imports = [
    ./unfree.nix

    ../../profiles/interactive.nix
    ../../profiles/addon-laptop.nix

    ../../mixins/cfdyndns.nix
    ../../mixins/github-runner.nix
    ../../mixins/iwd-networks.nix
    ../../mixins/plex.nix
    ../../mixins/rclone-googledrive-mounts.nix
    ../../mixins/syncthing.nix

    ./zrepl.nix
    # ./services/monitoring.nix

    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
  ];

  config = {
    nixpkgs.hostPlatform.system = "x86_64-linux";
    system.stateVersion = "23.11";

    networking.hostName = hn;
    # nixcfg.common.hostColor = "#59d600";
    nixcfg.common.hostColor = "green";
    nixcfg.common.wifiWorkaround = true;

    services.tailscale.useRoutingFeatures = "server";

    services.zfs.autoScrub.pools = [ poolname ];

    services.logind.extraConfig = ''
      HandlePowerKey=ignore
      HandleLidSwitch=ignore
    '';

    systemd.network = {
      enable = true;
      # networks."15-eth0-static-ip" = {
      #   matchConfig.Path = "pci-0000:03:00.3-usb-0:1:1.0";
      #   addresses = [{ addressConfig = { Address = static_ip; }; }];
      #   networkConfig = {
      #     Gateway = "192.168.1.1";
      #     DHCP = "no";
      #   };
      # };
    };

    fileSystems = {
      "/" = { fsType = "zfs"; device = "${poolname}/root"; neededForBoot = true; };
      "/home" = { fsType = "zfs"; device = "${poolname}/home"; neededForBoot = true; };
      "/nix" = { fsType = "zfs"; device = "${poolname}/nix"; neededForBoot = true; };
      "/boot" = { fsType = "vfat"; device = "/dev/disk/by-partlabel/${bootpart}"; neededForBoot = true; };
    };
    swapDevices = [{ device = "/dev/disk/by-partlabel/${swappart}"; }];

    boot = {
      kernelModules = [ "iwlwifi" "ideapad_laptop" ];
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
