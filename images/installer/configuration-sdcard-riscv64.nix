{ lib, inputs, ... }:

{
  imports = [
    ../../profiles/addon-riscv64-fixes.nix

    ./configuration-base.nix

    "${inputs.nixos-hardware}/spacemit/k3-pico-itx/sd-image.nix"
  ];

  config = {
    nixpkgs.hostPlatform.system = "riscv64-linux";

    sdImage.compressImage = false;

    nixcfg.common.useZfs = false;

    # system.etc.overlay.enable = lib.mkForce false;
    # system.nixos-init.enable = lib.mkForce false;
    # boot.initrd.systemd.enable = lib.mkForce false;

    boot.supportedFilesystems = lib.mkForce [
      "btrfs"
      "ext4"
      "vfat"
      "f2fs"
      "xfs"
      "ntfs"
    ];
  };
}
