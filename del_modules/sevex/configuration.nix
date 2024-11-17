{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  hn = "sevex";
in
{
  imports = [
    inputs.nixos-snapdragon-elite.nixosModules.default

    ../../profiles/gui-sway.nix

    ../../profiles/addon-devtools.nix
    # ../../profiles/addon-gaming.nix
    ../../profiles/addon-laptop.nix

    ../../mixins/gfx-radeonsi.nix
    ../../mixins/gfx-debug.nix

    ../../mixins/android.nix
    ../../mixins/clamav.nix
    # not available for aarch64-linux, fucking appimages
    # ../../mixins/ledger.nix
    ../../mixins/libvirt.nix
    ../../mixins/libvirtd.nix
    ../../mixins/monero.nix
    ../../mixins/podman.nix
    ../../mixins/spotify.nix
    ../../mixins/syncthing.nix
    ../../mixins/trezor.nix

    # ./experimental.nix
    ./unfree.nix

    # TODO, test this:
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.nyx.nixosModules.default
  ];

  config = {
    nixpkgs.hostPlatform = "aarch64-linux";
    system.stateVersion = "24.05";

    chaotic.mesa-git.enable = true;

    networking.hostName = hn;
    # nixcfg.common.hostColor = "#c17ecc"; # tango magenta
    nixcfg.common.hostColor = "magenta";
    nixcfg.common.skipMitigations = false;

    # zfs schenanigans
    nixcfg.common.useZfs = false;
    nixcfg.common.useZfsUnstable = false;
    nixcfg.common.defaultKernel = false;

    nix = {
      settings = {
        max-jobs = lib.mkForce 6;
      };
    };

    environment.systemPackages = with pkgs; [ esphome ];

    environment.variables = {
      MESA_LOADER_DRIVER_OVERRIDE = "zink";
    };

    services.tailscale.useRoutingFeatures = "client";

    time.timeZone = lib.mkForce null; # we're on the move

    boot.supportedFilesystems = lib.mkForce [
      "btrfs"
      "cifs"
      "f2fs"
      "jfs"
      "ntfs"
      "reiserfs"
      "vfat"
      "xfs"
    ];

    ## TODO: experimental
    services.dbus.implementation = "broker";
    ## END experimental

    fileSystems = {
      "/efi" = {
        fsType = "vfat";
        device = "/dev/nvme0n1p1";
      };
      "/boot" = {
        fsType = "vfat";
        device = "/dev/disk/by-partlabel/${hn}-boot";
      };
      "/" = {
        fsType = "ext4";
        device = "/dev/disk/by-partlabel/${hn}-root";
        neededForBoot = true;
      };

      # # TODO: only with lanzaboote
      # "/efi/EFI/Linux" = {
      #   device = "/boot/EFI/Linux";
      #   options = [ "bind" ];
      # };
      # "/efi/EFI/nixos" = {
      #   device = "/boot/EFI/nixos";
      #   options = [ "bind" ];
      # };
    };
    swapDevices = [ { device = "/dev/disk/by-partlabel/${hn}-swap"; } ];

    home-manager.users.cole =
      { pkgs, config, ... }@hm:
      {
        # hm stuff
      };
  };
}
