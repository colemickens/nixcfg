{ config, lib, pkgs, modulesPath, inputs, ... }:

# this is because we can trivially boot into windows (slywin)
# and then repair slynux from there

# TESTING:
# - (TODO) stage-1-systemd
# - (TODO) bootspec (grub?)
# - (TODO) ???

let
  hn = "slynux";
  
  bridgeName = "wanbr0";
  bridgeClients = {
    blueline1 = { match.Driver = "rndis_host"; };
    enchilada1 = { match.Driver = "cdc_ether"; };
  };
  staticNetworkConf = {
    enable = true;
  };
  mkNetworkBindToBridge = (k: v: {
    # this is large enough to come after we bond the bridge/bond
    # but comes before our catch-all rules to add everything else to the bond
    networks."30-${k}" = {
      matchConfig = v.match;
      networkConfig.Bridge = bridgeName;
    };
    networks."20-block-ms-wifi" = {
      matchConfig.Driver = "mt76x2u";
      linkConfig.Unmanaged = true;
    };
  });
  bridgeConfs = (lib.fold lib.recursiveUpdate { } (lib.mapAttrsToList mkNetworkBindToBridge bridgeClients));
  systemdNetworkVal = lib.recursiveUpdate staticNetworkConf bridgeConfs;
in
{
  imports = [
    ../../profiles/sway

    # TODO: move to nixos-hardware
    # eat my asshole nvidia, my gaming pc/server is crashing w/ the vga light keeps lit up...
    # ../../mixins/gfx-nvidia.nix
      
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

    ./unfree.nix
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-pc-ssd
    # inputs.hardware.nixosModules.common-gpu-nvidia
  ];

  config = {
    system.stateVersion = "21.05";

    networking.hostName = "slynux";
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
      "hyperv_drm"
    ];

    fileSystems = let hn = config.networking.hostName; in
      {
        "/" = { fsType = "zfs"; device = "${hn}pool/root"; };
        "/nix" = { fsType = "zfs"; device = "${hn}pool/nix"; };
        "/home" = { fsType = "zfs"; device = "${hn}pool/home"; };
        # "/persist" = { fsType = "zfs"; device = "${hn}pool/persist"; }; # TODO
        "/boot" = { fsType = "vfat"; device = "/dev/disk/by-partlabel/${hn}-boot"; };
      };

    boot.initrd.luks.devices."${hn}-luks" = {
      allowDiscards = true;
      device = "/dev/disk/by-partlabel/${hn}-luks";

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
