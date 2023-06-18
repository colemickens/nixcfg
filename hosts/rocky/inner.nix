{ pkgs, lib, modulesPath, inputs, config, extendModules, ... }:

let
  static_ip = "192.168.2.30/16";
  kernel = pkgs.callPackage ./kernel.nix { };
  kernelPackages = pkgs.linuxKernel.packagesFor kernel;
  hn = "rocky";
  pp = "rockfiveb1"; # part prefix different than hn

  rocky-flash-uboot =
    let
      fw = inputs.self.outputs.extra.x86_64-linux.rocky-firmware.firmware;
    in
    pkgs.writeShellScriptBin "rocky-flash-uboot" ''
      set -x
      set -euo pipefail

      # zero it
      zcat ${fw}/zero.img.gz | sudo dd if=/dev/stdin of=/dev/mtdblock0 conv=fsync status=progress
      sudo sync

      # flash the spi rockchip u-boot img
      sudo dd if=${fw}/binaries/u-boot-rockchip-spi.bin of=/dev/mtdblock0 conv=fsync status=progress
      sudo sync
    '';

  # vf2-flash-sdcard =
  #   let
  #     sdimage = inputs.self.outputs.extra.x86_64-linux.vf2-cross-sdimage.outPath;
  #     imageName = inputs.self.outputs.nixosConfigurations.vf2-cross.config.system.build.sdImage.imageName;
  #     dev = "/dev/disk/by-path/platform-fc800000.usb-usb-0:1.2:1.0-scsi-0:0:0:0";
  #     sd = "${sdimage}/sd-image/${imageName}.zst";
  #   in
  #   pkgs.writeShellScriptBin "vf2-flash-sdcard" ''
  #     set -x
  #     set -euo pipefail
  #     sudo wipefs -f -a ${dev}
  #     zstdcat ${sd} | sudo dd if=/dev/stdin of=${dev} bs=4M status=progress conv=fsync;
  #     sudo sync
  #   '';
in
{
  imports = [
    ../../profiles/core.nix
    ../../mixins/iwd-networks.nix
    ./unfree.nix

    inputs.tow-boot-radxa-rock5b.nixosModules.default
  ];
  config = {
    nixpkgs.hostPlatform.system = "aarch64-linux";
    system.stateVersion = "22.11";

    nixpkgs.overlays = [
      (final: super: {
        makeModulesClosure = x:
          super.makeModulesClosure (x // { allowMissing = true; });
      })
    ];

    nixcfg.common = {
      useZfs = false;
      defaultKernel = false;
      addLegacyboot = false;
    };
    networking.wireless.iwd.enable = true;

    fileSystems = lib.mkDefault {
      "/boot" = {
        fsType = "vfat";
        device = "/dev/disk/by-partlabel/${pp}-boot";
      };
      "/" = {
        fsType = "ext4";
        device = "/dev/disk/by-partlabel/${pp}-nixos";
      };
    };

    # system.build.sdImageX = (mkSpecialisation).config.system.build.sdImage;

    networking.hostName = hn;
    system.build = rec {
      mbr_disk_id = "888885b1";
    };

    systemd.network = {
      enable = true;
      networks."15-eth0-static-ip" = {
        matchConfig.Driver = "r8152";
        addresses = [{ addressConfig = { Address = static_ip; }; }];
        networkConfig = {
          Gateway = "192.168.1.1";
          DHCP = "no";
        };
      };
    };

    boot.kernelPackages = kernelPackages;
    boot.loader = {
      grub.enable = false;
      systemd-boot.enable = false;
      generic-extlinux-compatible = {
        enable = true;
      };
    };

    tow-boot = {
      enable = true;
      autoUpdate = false;
      device = "radxa-rock5b";
      config = {
        # device.identifier = "radxa-rock5b";
        # Tow-Boot = {
        #   defconfig = "rock-5b-rk3588_defconfig";
        # };
      };
    };
  };
}
