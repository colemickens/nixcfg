{ config, lib, pkgs, modulesPath, inputs, ... }:

let
  hn = "slynux";
in
{
  imports = [
    ../../profiles/sway
    ../../profiles/interactive.nix
    ../../profiles/dev.nix

    ../../mixins/gfx-nvidia.nix
    ../../mixins/gfx-debug.nix

    ../../mixins/android.nix
    ../../mixins/grub-signed-shim.nix
    ../../mixins/rclone-googledrive-mounts.nix
    ../../mixins/sshd.nix
    ../../mixins/syncthing.nix
    ../../mixins/tailscale.nix
    ../../mixins/zfs.nix

    ./unfree.nix

    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    # inputs.nixos-hardware.nixosModules.common-gpu-nvidia
  ];

  config = {
    system.stateVersion = "21.05";
    networking.hostName = "slynux";

    nixcfg.common.defaultNetworking = false;
    nixcfg.common.hostColor = "blue";

    systemd.network.wait-online.anyInterface = true; # untested here
    networking = {
      # TODO: try this again with hand-crafted so we can match on wildcards for bridged usb devices
      useNetworkd = true;
      interfaces."eno1".useDHCP = true;
      interfaces."wanbr0".useDHCP = true;
      bridges."wanbr0" = {
        interfaces = [
          "eno1"
          "enp4s0f3u1u1" # android phone
        ];
      };
    };

    boot = {
      tmpOnTmpfs = true;
      loader.grub.configurationLimit = lib.mkForce 20;
      initrd = {
        availableKernelModules = [ "sd_mod" "sr_mod" ];
        kernelModules = [
          "xhci_pci"
          "nvme"
          "usb_storage"
          "sd_mod"
          "ehci_pci"
          "uas"
        ];
        luks.devices."nixos-luksroot" = {
          device = "/dev/disk/by-partlabel/${hn}-luks";
          allowDiscards = true;
          keyFile = "/lukskey";
          fallbackToPassword = true;
        };
        secrets."/lukskey" = pkgs.writeText "lukskey" "test";
      };
    };

    fileSystems = {
      "/" = { fsType = "zfs"; device = "${hn}pool/root"; };
      "/nix" = { fsType = "zfs"; device = "${hn}pool/nix"; };
      "/home" = { fsType = "zfs"; device = "${hn}pool/home"; };
      "/boot" = { fsType = "vfat"; device = "/dev/disk/by-partlabel/${hn}-boot"; };
    };
    swapDevices = [ ];
  };
}
