{ pkgs, inputs, ... }:

let
  hn = "slynux";
  pp = "slynux"; # ?
  swappart = "slynux-swap";
  asVm = false;
in
{
  imports = [
    ./unfree.nix
    ../../profiles/interactive.nix
    ../../profiles/addon-devtools.nix
    ../../mixins/common.nix

    # ../../mixins/rclone-googledrive-mounts.nix
    ../../mixins/sshd.nix
    ../../mixins/syncthing.nix
    ../../mixins/tailscale.nix

    #./go2rtc.nix
    ./restic.nix
    ./nginx-vaultwarden.nix

    inputs.determinate-main.nixosModules.default

    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    # inputs.nixos-hardware.nixosModules.common-gpu-nvidia
  ];

  config = {
    nixpkgs.hostPlatform.system = "x86_64-linux";
    system.stateVersion = "23.11";

    networking.hostName = hn;
    nixcfg.common.hostColor = "blue";

    services.tailscale.useRoutingFeatures = "server";

    fileSystems = {
      "/boot" = {
        fsType = "vfat";
        device = "/dev/disk/by-partlabel/${pp}-boot";
      };
      "/" = {
        fsType = "zfs";
        device = "${pp}pool/root";
      };
      "/nix" = {
        fsType = "zfs";
        device = "${pp}pool/nix";
      };
      "/home" = {
        fsType = "zfs";
        device = "${pp}pool/home";
      };
    };
    swapDevices = [ { device = "/dev/disk/by-partlabel/${swappart}"; } ];

    boot = {
      tmp = {
        useTmpfs = false; # this seems to not give enough RAM for a kernel build
        cleanOnBoot = true;
      };
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
          device = "/dev/disk/by-partlabel/${hn}-luksroot";
          allowDiscards = true;
          keyFile = "/lukskey";
        };
      };
      initrd.secrets."/lukskey" = pkgs.writeText "lukskey" "test";
    };
  };
}
