{ pkgs
, lib
, modulesPath
, inputs
, config
, extendModules
, ...
}:

{
  imports = [
    ./base.nix
    ../../profiles/addon-tiny.nix
  ];

  config = {
    # NOTE(colemickens): mesa currently failing to cross-compile
    hardware.graphics.enable = lib.mkForce false;

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
