{ config, lib, pkgs, modulesPath, nix-coreboot, inputs, ... }:

let
  ncb = inputs.nix-coreboot;
  cb = ncb.lib.buildCoreboot {
    name = "coreboot-asus-p77h-i";
    system = pkgs.hostPlatform.system;
    crossSystem = lib.systems.examples.gnu32;
    configText = builtins.readFile ./coreboot-config;
  };
in
{
  imports = [
    ../../profiles/sway

    ../../mixins/gfx-intel.nix

    ../../mixins/grub-signed-shim.nix
    ../../mixins/sshd.nix
    ../../mixins/tailscale.nix
    ../../mixins/zfs.nix

    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];

  config = {
    system.build.coreboot = cb;
    
    system.stateVersion = "21.05";

    networking.hostName = "linbio";

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

    boot.initrd.luks.devices."nixos-luksroot" = {
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
