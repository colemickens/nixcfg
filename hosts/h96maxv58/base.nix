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
  ubootH96 = inputs.h96.outputs.packages.aarch64-linux.ubootH96MaxV58;
in
{
  imports = [
    # inputs.h96.outputs.nixosModules.base-config
    inputs.h96.outputs.nixosModules.kernel-config
    inputs.h96.outputs.nixosModules.device-tree

    inputs.disko.nixosModules.disko

    ../../profiles/core.nix
    ../../profiles/user-cole.nix
    ../../profiles/user-jeff.nix

    ../../mixins/common.nix
    ../../mixins/iwd-networks.nix
    ../../mixins/sshd.nix
    ../../mixins/tailscale.nix
    ../../mixins/unifi.nix
  ];

  config = {
    nixpkgs.hostPlatform.system = "aarch64-linux";

    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "armbian-firmware"
      "armbian-firmware-unstable"
      "unifi-controller"
      "mongodb"
    ];

    disko.memSize = 4096; # TODO: fix make-disk-image.nix to output script that defaults to this, so annoying!!!!1111 or warn if used with impure!
    disko.extraPostVM = ''
      (
        set -x
        # TODO: GROSS TO HARDCODE, GROSSER THAT THE EXAMPLE WOULD CLOBBER HOME/*.RAW if it worked...
        disk=$out/disk0.raw
        ${pkgs.coreutils}/bin/dd if=${ubootH96}/u-boot-rockchip.bin of=$disk seek=64 bs=512 conv=notrunc
        ${pkgs.zstd}/bin/zstd --compress $disk
        rm $disk
      )
    '';
    disko.devices.disk.disk0 = {
      type = "disk";
      imageSize = "4G";
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
          rootfs = {
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };

    nixpkgs.overlays = [
      (final: super: {
        makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
      })
    ];

    environment.systemPackages = with pkgs; [
      evtest
      ripgrep
      picocom
      zellij
      pulsemixer
      bottom
    ];

    hardware.firmware = [ pkgs.armbian-firmware ];

    services.pipewire.enable = true;
    services.pipewire.pulse.enable = true;

    nixcfg.common.useZfs = false;
    nixcfg.common.defaultKernel = false;
    nixcfg.common.wifiWorkaround = true;

    boot.loader.systemd-boot.enable = true;
    boot.loader.systemd-boot.installDeviceTree = true;

    networking.wireless.enable = lib.mkForce false;
    networking.wireless.iwd.enable = true;

    networking.hostName = hn;
    system.stateVersion = "24.05";
  };
}
