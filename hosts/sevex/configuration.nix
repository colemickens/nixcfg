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
    inputs.nixos-snapdragon-elite.nixosModules.snapdragon

    ../../profiles/addon-asus.nix
    ../../profiles/addon-devtools.nix
    ../../profiles/addon-gaming.nix
    ../../profiles/addon-laptop.nix

    ../../mixins/gfx-radeonsi.nix
    ../../mixins/gfx-debug.nix

    ../../mixins/android.nix
    ../../mixins/clamav.nix
    ../../mixins/ledger.nix
    ../../mixins/libvirt.nix
    ../../mixins/libvirtd.nix
    ../../mixins/monero.nix
    ../../mixins/podman.nix
    ../../mixins/spotify.nix
    ../../mixins/syncthing.nix
    ../../mixins/trezor.nix

    ./zrepl.nix # TODO: make this device specific

    # ../../mixins/oavm-risky.nix

    # ./experimental.nix
    ./unfree.nix

    # TODO, test this:
    # inputs.lanzaboote.nixosModules.lanzaboote
  ];

  config = {
    nixpkgs.hostPlatform = "aarch64-linux";
    system.stateVversion = "24.05";

    networking.hostName = hn;
    # nixcfg.common.hostColor = "#c17ecc"; # tango magenta
    nixcfg.common.hostColor = "magenta";
    nixcfg.common.skipMitigations = false;

    # zfs schenanigans
    nixcfg.common.useZfs = true;
    nixcfg.common.useZfsUnstable = true;

    nix = {
      settings = {
        max-jobs = lib.mkForce 6;
      };
    };

    environment.systemPackages = with pkgs; [ esphome ];

    services.tailscale.useRoutingFeatures = "client";

    time.timeZone = lib.mkForce null; # we're on the move

    ## TODO: experimental
    services.dbus.implementation = "broker";
    ## END experimental

    services.zfs.autoScrub.pools = [ poolname ];
    fileSystems = {
      "/efi" = {
        fsType = "vfat";
        device = "/dev/nvme0n1p1";
      };
      "/boot" = {
        fsType = "vfat";
        device = "/dev/disk/by-partlabel/${bootpart}";
      };
      "/" = {
        fsType = "zfs";
        device = "${poolname}/root";
        neededForBoot = true;
      };
      "/nix" = {
        fsType = "bcachefs";
        device = "${poolname}/nix";
        neededForBoot = true;
      };
      "/home" = {
        fsType = "bcachefs";
        device = "${poolname}/home";
        neededForBoot = true;
      };

      # TODO: only with lanzaboote
      # "/efi/EFI/Linux" = {
      #   device = "/boot/EFI/Linux";
      #   options = [ "bind" ];
      # };
      # "/efi/EFI/nixos" = {
      #   device = "/boot/EFI/nixos";
      #   options = [ "bind" ];
      # };
    };
    swapDevices = [ { device = "/dev/disk/by-partlabel/${swappart}"; } ];

    home-manager.users.cole =
      { pkgs, config, ... }@hm:
      {
        # hm stuff
      };
  };
}
