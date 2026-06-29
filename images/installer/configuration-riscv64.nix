{ lib, ... }:

{
  imports = [
    ./configuration-base.nix
  ];

  config = {
    nixpkgs.hostPlatform.system = "riscv64-linux";

    nixcfg.common.defaultKernel = lib.mkForce true;
    nixcfg.common.useZfs = lib.mkForce false;

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
