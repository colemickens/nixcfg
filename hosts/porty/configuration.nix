{ config, lib, pkgs, modulesPath, inputs, ... }:

# TODO: rename porty back to slynux again

# porty is our testbed device
# this is because we can trivially boot into windows (slywin)
# and then repair slynux from there

# TESTING:
# - (TODO) stage-1-systemd
# - (TODO) bootspec (grub?)
# - (TODO) ???

let
  bridgeName = "br0";
  bridgeClients = {
    blueline1 = { match.Driver = "rndis_host"; };
    enchilada1 = { match.Driver = "cdc_ether"; };
  };
  staticNetworkConf = {
    enable = true;
    netdevs."10-netdev-br0" = {
      netdevConfig.Name = bridgeName;
      netdevConfig.Kind = "bridge";
    };
    networks."20-bind-brphone-eth" = {
      matchConfig.Name = "eno1|eth0|enp8s0";
      networkConfig = {
        Bridge = bridgeName;
        IPv6AcceptRA = true;
      };
    };
    networks."25-network-brphone" = {
      matchConfig.Name = bridgeName;
      networkConfig = {
        DHCP = "yes";
        IPv6AcceptRA = true;
        DHCPv6PrefixDelegation = "yes";
        Use6RD = true;
        IPForward = "yes";
      };
      dhcpV6Config.PrefixDelegationHint = "::64";
      ipv6PrefixDelegationConfig.Managed = true;
      linkConfig.RequiredForOnline = "routable";
    };
  };
  mkNetworkBindToBridge = (k: v: {
    networks."30-${k}" = {
      matchConfig = v.match;
      networkConfig.Bridge = bridgeName;
    };
  });
  bridgeConfs = (lib.fold lib.recursiveUpdate { } (lib.mapAttrsToList mkNetworkBindToBridge bridgeClients));
  systemdNetworkVal = lib.recursiveUpdate staticNetworkConf bridgeConfs;
in
{
  imports = [
    ../../profiles/sway

    # TODO: move to nixos-hardware
    ../../mixins/gfx-nvidia.nix
    ../../mixins/gfx-debug.nix

    ../../mixins/android.nix
    ../../mixins/devshells.nix
    ../../mixins/grub-signed-shim.nix
    ../../mixins/logitech-mouse.nix
    ../../mixins/rclone-googledrive-mounts.nix
    ../../mixins/sshd.nix
    ../../mixins/syncthing.nix
    ../../mixins/tailscale.nix
    ../../mixins/zfs.nix

    ./qemu-cross-arch.nix
    ./unfree.nix
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-pc-ssd
    # inputs.hardware.nixosModules.common-gpu-nvidia
  ];

  config = {
    system.stateVersion = "21.05";

    networking.hostName = "porty";
    systemd.network = systemdNetworkVal;

    hardware.usbWwan.enable = true;

    virtualisation.hypervGuest.enable = true; # dualboot: Linux, Win11(hyper-v guest)

    boot.loader.grub.pcmemtest.enable = true;
    boot.initrd.availableKernelModules = [ "sd_mod" "sr_mod" ];
    boot.initrd.kernelModules = [
      "xhci_pci"
      "nvme"
      "usb_storage"
      "sd_mod"
      "ehci_pci"
      "uas"
    ];

    fileSystems = let hn = config.networking.hostName; in
      {
        "/" = { fsType = "zfs"; device = "${hn}pool/root"; };
        "/nix" = { fsType = "zfs"; device = "${hn}pool/nix"; };
        "/home" = { fsType = "zfs"; device = "${hn}pool/home"; };
        # "/persist" = { fsType = "zfs"; device = "${hn}pool/persist"; }; # TODO
        "/boot" = { fsType = "vfat"; device = "/dev/disk/by-partlabel/${hn}-boot"; };
      };

    boot.initrd.luks.devices."porty-luks" = {
      allowDiscards = true;
      device = "/dev/disk/by-partlabel/porty-luks";

      # TODO: Finish:
      # ./misc/hyperv/make-luks-disk.sh
      keyFile = "/lukskey";
      fallbackToPassword = true;
    };
    # TODO: subsequently remove, and then purge old generations and initrds and rotate
    # keys
    boot.initrd.secrets = {
      "/lukskey" = pkgs.writeText "lukskey" "test";
    };

    swapDevices = [ ];
  };
}
