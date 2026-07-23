{ lib, inputs, ... }:

{
  imports = [
    ../../profiles/addon-riscv64-fixes.nix

    ./configuration-base.nix

    "${inputs.nixos-hardware}/spacemit/k3-pico-itx"
  ];

  config = {
    nixpkgs.hostPlatform.system = "riscv64-linux";

    nixcfg.common.defaultKernel = lib.mkForce true;
    nixcfg.common.useZfs = lib.mkForce false;

    system.nixos-init.enable = false;

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
