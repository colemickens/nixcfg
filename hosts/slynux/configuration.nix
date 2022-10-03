{ config, lib, pkgs, modulesPath, inputs, ... }:

# this is because we can trivially boot into windows (slywin)
# and then repair slynux from there

# TESTING:
# - (TODO) stage-1-systemd
# - (TODO) bootspec (grub?)
# - (TODO) ???

let
  hn = "slynux";
  
  # bridgeName = "wanbr0";
  # bridgeClients = {
  #   blueline1 = { match.Driver = "rndis_host"; };
  #   enchilada1 = { match.Driver = "cdc_ether"; };
  # };
  # staticNetworkConf = {
  #   enable = true;
    
  #   newtorks."19-wanbr0-bridge" = {
  #     matchConfig.Driver = "";
  #     linkConfig = "";
  #   };
  #   networks."20-block-ms-wifi" = {
  #     # TODO: probably just blacklist the module?
  #     matchConfig.Driver = "mt76x2u";
  #     linkConfig.Unmanaged = true;
  #   };
  # };
  # mkNetworkBindToBridge = (k: v: {
  #   # this is large enough to come after we bond the bridge/bond
  #   # but comes before our catch-all rules to add everything else to the bond
  #   networks."20-${k}" = {
  #     matchConfig = v.match;
  #     networkConfig.Bridge = bridgeName;
  #   };
  # });
  # bridgeConfs = (lib.fold lib.recursiveUpdate { } (lib.mapAttrsToList mkNetworkBindToBridge bridgeClients));
  # systemdNetworkVal = lib.recursiveUpdate staticNetworkConf bridgeConfs;
in
{
  imports = [
    # ../../profiles/sway
    ../../profiles/interactive.nix

    # TODO: move to nixos-hardware
    # eat my asshole nvidia, my gaming pc/server is crashing w/ the vga light keeps lit up...
    ../../mixins/gfx-nvidia.nix
    ../../mixins/gfx-debug.nix

    ../../mixins/android.nix
    # ../../mixins/devshells.nix
    ../../mixins/devtools.nix
    ../../mixins/grub-signed-shim.nix
    # ../../mixins/logitech-mouse.nix
    ../../mixins/rclone-googledrive-mounts.nix
    ../../mixins/sshd.nix
    ../../mixins/syncthing.nix
    ../../mixins/tailscale.nix
    ../../mixins/zfs.nix
    
    # ./services/homie-cast.nix

    ./unfree.nix
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-cpu-amd-pstate
    inputs.hardware.nixosModules.common-pc-ssd
    # inputs.hardware.nixosModules.common-gpu-nvidia
  ];

  config = {
    system.stateVersion = "21.05";
    networking.hostName = "slynux";
    
    nixcfg.common.defaultNetworking = false;
    # systemd.network.wait-online.ignoredInterfaces = [ "wanbr0" ]; # since it's bridged?
    systemd.network.wait-online.anyInterface = true; # untested here
    networking = {
      firewall.allowedTCPPorts = [ 7860 7861 ];
      # hm, this is much nicer than doing it by hand...
      # but, for example, I can't match on not-the-name, which 
      # changes a lot with my stupid rdnis/usb devices, etc
      useNetworkd = true;
      interfaces."eno1".useDHCP = true;
      # eno1 should use a static ip, currently gets "192.168.30.181" but we'd rather static it to "192.168.1.20" maybe to match xeep
      interfaces."wanbr0".useDHCP = true;
      bridges."wanbr0" = {
        interfaces = [
          "eno1"

          "enp4s0f3u1u1"
          "enp4s0f3u1u2"
          "enp4s0f3u1u3"
          "enp4s0f3u1u4"
          "enp4s0f3u1u5"

          "enp5s0f0u4u1"
          "enp5s0f0u4u2"
          "enp5s0f0u4u3"
          "enp5s0f0u4u4"
          "enp5s0f0u4u5"
        ];
      };
    };
    # systemd.network = systemdNetworkVal;

    hardware.usbWwan.enable = true;
    hardware.cpu.amd.updateMicrocode = true;

    # TODO: disabled, we suspect hyperv for zfs corruption
    # virtualisation.hypervGuest.enable = true; # dualboot: Linux, Win11(hyper-v guest)

    boot.loader.grub.pcmemtest.enable = true;
    boot.loader.grub.configurationLimit = 20;
    boot.initrd.availableKernelModules = [ "sd_mod" "sr_mod" ];
    boot.initrd.kernelModules = [
      "xhci_pci"
      "nvme"
      "usb_storage"
      "sd_mod"
      "ehci_pci"
      "uas"
      # "hyperv_drm"
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
      
      ## TODO: uncomment if we want auto-unlock and/or hyperv, for now we're blocking
      ## hyperv though due to suspected ZFS corruption...
      keyFile = "/lukskey";
      fallbackToPassword = true;
    };

    boot.initrd.secrets = {
      # TODO: subsequently remove, and then purge old generations and initrds and rotate
      # keys
      "/lukskey" = pkgs.writeText "lukskey" "test";
    };

    swapDevices = [ ];
  };
}
