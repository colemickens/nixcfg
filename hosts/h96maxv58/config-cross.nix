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

    ../../mixins/tailscale.nix
    ../../mixins/unifi.nix
  ];

  config = {
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      # TODO: wtf, why do I have to duplicate these from base.nix?
      "armbian-firmware"
      "armbian-firmware-unstable"
      "unifi-controller"
      "mongodb"
    ];

    environment.systemPackages = with pkgs; [
      evtest
      ripgrep
      zellij
      pulsemixer
      bottom
    ];

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
