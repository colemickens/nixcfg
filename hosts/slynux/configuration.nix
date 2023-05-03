{ pkgs, lib, inputs, modulesPath, ... }:
let
  hn = "slynux";
  asVm = true;
in
{
  imports = [
    ../../mixins/common.nix
    ../../mixins/sshd.nix
    ../../mixins/tailscale.nix

    ../../profiles/gui-sway-auto.nix
    ../../profiles/interactive.nix
  ] ++ (if asVm then [
    ../../profiles/addon-auto-vm.nix
  ] else [
    ../../mixins/gfx-nvidia.nix
  ]);

  config = {
    nixpkgs.hostPlatform.system = "x86_64-linux";
    system.stateVersion = "22.11";

    networking.hostName = hn;
    nixcfg.common.hostColor = "blue";

    services.tailscale.useRoutingFeatures = "server";

    # TODO: remove this is only for the VM
    services.timesyncd.enable = lib.mkForce false;

    fileSystems = {
      "/boot" = { fsType = "vfat"; device = "/dev/disk/by-partlabel/slynuxreborn_boot"; };
      "/" = { fsType = "zfs"; device = "slynuxreborn/root"; };
      "/home" = { fsType = "zfs"; device = "slynuxreborn/home"; };
      "/nix" = { fsType = "zfs"; device = "slynuxreborn/nix"; };
    };
    swapDevices = [ ];

    boot = {
      # tmpOnTmpfs = true;  # re-enable when RAM RMA is complete and we're back to 64GB
      #zfs.requestEncryptionCredentials = true;
      initrd.availableKernelModules = [
        "xhci_pci"
        "nvme"
        "usb_storage"
        "sd_mod"
        "rtsx_pci_sdmmc"
        "intel_agp"
        "i915"
      ];
      initrd.luks.devices = {
        "nixos-luksroot" = {
          name = "nixos-luksroot";
          device = "/dev/disk/by-partlabel/slynuxreborn_luks";
          preLVM = true;
          allowDiscards = true;

          # disabling this for now
          # so that it doesn't work in Win10
          # see if its the cause of corruption

          #keyFile = "/dev/sdb";
          #keyFileSize = 4096;
        };
      };
    };
  };
}
