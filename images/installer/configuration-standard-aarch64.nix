{ pkgs, lib, ... }:

let
  hn = "installer-standard";
in
{
  imports = [
    ./configuration-base-installer.nix
  ];

  config = {
    networking.hostName = hn;
    system.nixos.tags = [
      "standard"
      "aarch64"
    ];

    # jesus christ, gobject-inspection, gpgme, ruby? fuck no
    services.udisks2.enable = lib.mkForce false;
    networking.modemmanager.enable = lib.mkForce false;

    nixcfg.common.defaultKernel = lib.mkForce false;
    nixcfg.common.useZfs = lib.mkForce false;
    boot.supportedFilesystems = lib.mkForce [
      "btrfs"
      "ext4"
      "vfat"
      "f2fs"
      "xfs"
      "ntfs"
    ];

    boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;

    nixpkgs.hostPlatform.system = "aarch64-linux";
  };
}
