{ lib, inputs, ... }:

{
  imports = [
    ../../profiles/addon-riscv64-fixes.nix

    ./configuration-base.nix

    "${inputs.nixos-hardware}/spacemit/k3-pico-itx/sd-image.nix"
  ];

  config = {
    nixpkgs.hostPlatform.system = "riscv64-linux";

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
