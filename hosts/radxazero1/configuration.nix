{ pkgs, lib, modulesPath, extendModules, inputs, config, ... }:

let
  eth_ip = "192.168.162.69/16";
in
{
  imports = [
    # TODO: no sdcard here...?

    ../../profiles/core.nix
    ../../mixins/iwd-networks.nix

    ../../mixins/pipewire.nix

    ../../profiles/addon-tiny.nix
    # ../../profiles/gui-sway-auto.nix # broken, librsvg, again, lol

    ./unfree.nix

    # inputs.tow-boot-radxa-zero.nixosModules.default
  ];

  config = {
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "meson64-tools"
    ];

    # try to fix hdmi audio:
    # hardware.deviceTree.overlays = [
    #   {
    #     name = "fix-hdmi-audio";
    #     dtsText = ''
    #       /dts-v1/;
    #       /plugin/;
    #       / {
    #       	compatible = "radxa,zero", "amlogic,g12a";
    #       	fragment@0 {
    #       		target-path = "/soc/bus@ff800000/i2c@5000";
    #       		__overlay__ {
    #       			status = "okay";
    #       		};
    #       	};
    #       	fragment@1 {
    #       		target-path = "/soc/bus@ffd00000/i2c@1d000";
    #       		__overlay__ {
    #       			status = "okay";
    #       		};
    #       	};
    #       	fragment@2 {
    #       		target-path = "/soc/bus@ffd00000/i2c@1f000";
    #       		__overlay__ {
    #       			status = "okay";
    #       		};
    #       	};
    #       	fragment@3 {
    #       		target-path = "/soc/bus@ffd00000/i2c@1e000";
    #       		__overlay__ {
    #       			status = "okay";
    #       		};
    #       	};
    #       };
    #     '';
    #   }
    # ];

    nixpkgs.hostPlatform.system = "aarch64-linux";

    nixcfg.common.useZfs = false;
    nixcfg.common.defaultNetworking = lib.mkForce true; # why rpi-sdcard??
    nixcfg.common.addLegacyboot = false;
    nixcfg.common.wifiWorkaround = true;

    networking.hostName = "radxazero1";
    system.stateVersion = "23.05";

    services.tailscale.useRoutingFeatures = "server";
    networking.wireless.iwd.enable = true;

    fileSystems = {
      "/" = { fsType = "ext4"; device = "/dev/disk/by-partlabel/zero-nixos"; };
      "/boot" = { fsType = "vfat"; device = "/dev/disk/by-partlabel/zero-boot"; };
    };
    swapDevices = [
      { device = "/dev/disk/by-partlabel/zero-swap"; }
    ];

    # boot.initrd.systemd.network.networks."10-eth0".addresses =
    #   [{ addressConfig = { Address = eth_ip; }; }];
    # system.build = rec {
    #   mbr_disk_id = "88888401";
    # };

    boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
    # boot.kernelPackages = lib.mkForce pkgs.linuxPackages_5_18;
    boot.loader = {
      grub.enable = false;
      systemd-boot.enable = false;
      generic-extlinux-compatible = {
        enable = true;
      };
    };

    # tow-boot.enable = true;
    # tow-boot.autoUpdate = false;
    # tow-boot.device = "radxa-zero";
    # # configuration.config.Tow-Boot = {
    # tow-boot.config = ({
    #   allowUnfree = true; # new, radxa specific
    #   diskImage.mbr.diskID = config.system.build.mbr_disk_id;
    #   uBootVersion = "2022.04";
    #   useDefaultPatches = false;
    #   withLogo = false;
    # });
  };
}
