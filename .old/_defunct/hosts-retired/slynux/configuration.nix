{ config, lib, pkgs, modulesPath, inputs, ... }:

let
  hn = "slynux";
in
{
  imports = [
    ../../profiles/interactive.nix

    ../../profiles/addon-dev.nix
    ../../profiles/addon-gaming.nix

    ../../mixins/gfx-nvidia.nix
    ../../mixins/gfx-debug.nix

    ../../mixins/syncthing.nix
    ../../mixins/zfs.nix

    ./unfree.nix

    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    # inputs.nixos-hardware.nixosModules.common-gpu-nvidia
  ];

  config = {
    nixpkgs.hostPlatform.system = "x86_64-linux";

    system.stateVersion = "21.05";
    networking.hostName = "slynux";

    nixcfg.common.hostColor = "blue";

    boot = {
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
