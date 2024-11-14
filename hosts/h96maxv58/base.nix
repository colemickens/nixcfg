{ pkgs
, lib
, modulesPath
, inputs
, config
, extendModules
, ...
}:

let
  hn = "h96maxv58";
in
{
  imports = [
    inputs.h96.outputs.nixosModules.kernel
    inputs.h96.outputs.nixosModules.device-tree
    inputs.h96.outputs.nixosModules.firmware

    inputs.disko.nixosModules.disko

    ../../profiles/core.nix
    ../../profiles/user-cole.nix
    ../../profiles/user-jeff.nix

    ../../mixins/common.nix
    ../../mixins/frigate.nix
    ../../mixins/iwd-networks.nix
    ../../mixins/sshd.nix

    ../../mixins/tailscale.nix
    ../../mixins/unifi.nix
  ];

  config = {
    system.stateVersion = "24.05";
    networking.hostName = hn;
    nixpkgs.hostPlatform = "aarch64-linux";

    nixpkgs.overlays = [
      inputs.h96.outputs.overlays.default
      (final: super: {
        makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
      })
    ];
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
      cyme
    ];

    services.udev.packages = with pkgs; [ libedgetpu ];

    hardware.graphics.enable = lib.mkForce false;

    services.pipewire.enable = true;
    services.pipewire.pulse.enable = true;

    nixcfg.common.useZfs = false;
    nixcfg.common.defaultKernel = false;
    nixcfg.common.wifiWorkaround = true;

    boot.loader.systemd-boot.enable = true;
    boot.loader.systemd-boot.installDeviceTree = true;

    networking.wireless.enable = lib.mkForce false;
    networking.wireless.iwd.enable = true;

    disko = {
      memSize = 4096; # TODO: fix make-disk-image.nix to output script that defaults to this, so annoying!!!!1111 or warn if used with impure!
      imageBuilder.extraPostVM = ''
        (
          set -x
          # TODO: GROSS TO HARDCODE, GROSSER THAT THE EXAMPLE WOULD CLOBBER HOME/*.RAW if it worked...
          disk=$out/disk0.raw
          ${pkgs.coreutils}/bin/dd if=${pkgs.uboot_h96maxv58}/u-boot-rockchip.bin of=$disk seek=64 bs=512 conv=notrunc
          ${pkgs.zstd}/bin/zstd --compress $disk
          rm $disk
        )
      '';
      devices.disk.disk0 = {
        # NOTE: imageSize must be large enough for swap size + rootfs closure
        type = "disk";
        imageSize = "14G";
        content = {
          type = "gpt";
          partitions = {
            empty = {
              priority = 1;
              start = "34";
              alignment = 1;
              end = "63";
              type = "0000";
            };
            firmware = {
              priority = 2;
              start = "64";
              size = "64M";
              alignment = 1;
              type = "0000";
            };
            ESP = {
              priority = 3;
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            swap = {
              priority = 4;
              size = "8G";
              type = "8200";
              content = {
                type = "swap";
              };
            };
            rootfs = {
              priority = 5;
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
