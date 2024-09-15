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
    # ../../mixins/frigate.nix
    ../../mixins/iwd-networks.nix
    ../../mixins/sshd.nix
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
      "armbian-firmware"
      "armbian-firmware-unstable"
    ];

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
            firmware = {
              start = "64";
              alignment = 1;
              end = "61440";
            };
            ESP = {
              start = "64M";
              end = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            swap = {
              start = "513M";
              size = "8G";
              type = "8200";
              content = {
                type = "swap";
              };
            };
            rootfs = {
              start = "9216M"; # = (9*1024)
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
