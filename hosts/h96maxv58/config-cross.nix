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
