{ pkgs, lib, inputs, modulesPath, ... }:
let
  hn = "slynux";
  pp = "slynux"; # ?
  asVm = false;
in
{
  imports = [
    ./unfree.nix
    ../../mixins/common.nix

    ../../mixins/android.nix
    ../../mixins/sshd.nix
    ../../mixins/syncthing.nix
    ../../mixins/tailscale.nix
    ../../mixins/zfs.nix

    ../../mixins/gfx-nvidia.nix

    # ../../profiles/gui-sway-auto.nix
    # ../../profiles/gui-sway.nix
    # ../../profiles/addon-gaming.nix
    ../../profiles/interactive.nix

    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    # inputs.nixos-hardware.nixosModules.common-gpu-nvidia
  ];

  config = {
    services.getty.autologinUser = "cole";
    environment.loginShellInit = ''
      [[ "$(tty)" == /dev/tty1 ]] && (
        set -x;
        sleep 1;
        # export WLR_RENDER="vulkan"
        sway &> $HOME/sway.log
      )
    '';

    nixpkgs.hostPlatform.system = "x86_64-linux";
    system.stateVersion = "22.11";

    networking.hostName = hn;
    nixcfg.common.hostColor = "blue";

    services.tailscale.useRoutingFeatures = "server";

    fileSystems = {
      "/boot" = { fsType = "vfat"; device = "/dev/disk/by-partlabel/${pp}-boot"; };
      "/" = { fsType = "zfs"; device = "${pp}pool/root"; };
      "/nix" = { fsType = "zfs"; device = "${pp}pool/nix"; };
      "/home" = { fsType = "zfs"; device = "${pp}pool/home"; };
    };
    swapDevices = [ ];

    boot = {
      # tmpOnTmpfs = true;  # re-enable when RAM RMA is complete and we're back to 64GB
      #zfs.requestEncryptionCredentials = true;
      initrd.availableKernelModules = [
        "sd_mod"
        "sr_mod"
        "xhci_pci"
        "nvme"
        "usb_storage"
        "sd_mod"
        "ehci_pci"
        "uas"
      ];
      initrd.systemd.enable = lib.mkForce false;
      kernelModules = [
        "xhci_pci"
        "nvme"
        "usb_storage"
        "sd_mod"
        "ehci_pci"
        "uas"
      ];
      initrd.luks.devices = {
        "nixos-luksroot" = {
          device = "/dev/disk/by-partlabel/${hn}-luks";
          allowDiscards = true;
          keyFile = "/lukskey";
        };
      };
      initrd.secrets."/lukskey" = pkgs.writeText "lukskey" "test";
    };
  };
}