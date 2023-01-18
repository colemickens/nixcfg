{ pkgs, lib, modulesPath, inputs, config, extendModules, ... }:

let
  # eth_ip = "192.168.162.69/16";
  kernel = pkgs.callPackage ./kernel.nix { };
  kernelPackages = pkgs.linuxKernel.packagesFor kernel;
  hn = "aitchninesix1";

  krnl = config.boot.kernelPackages.kernel;
in
{
  imports = [
    ../rockfiveb1/unfree.nix

    ../../modules/rsynstall.nix

    ../../profiles/user.nix
    ../../mixins/common.nix
    ../../mixins/tailscale.nix
    ../../mixins/sshd.nix
    # ../../mixins/iwd-networks.nix
    inputs.tow-boot-radxa-rock5b.nixosModules.default
  ];

  config = {
    nixpkgs.hostPlatform.system = "aarch64-linux";

    nixpkgs.overlays = [
      (final: super: {
        makeModulesClosure = x:
          super.makeModulesClosure (x // { allowMissing = true; });
      })
    ];

    environment.systemPackages = with pkgs; [
      evtest
      ripgrep
    ];

    fileSystems = lib.mkDefault {
      "/boot" = {
        fsType = "vfat";
        device = "/dev/disk/by-partlabel/${hn}-boot";
      };
      "/" = {
        fsType = "ext4";
        device = "/dev/disk/by-partlabel/${hn}-nixos";
      };
    };

    # system.build.sdImageX = (mkSpecialisation).config.system.build.sdImage;

    nixcfg.common = {
      useZfs = false;
      defaultKernel = false;
      defaultNetworking = false;
      sysdBoot = false;
    };

    networking.hostName = hn;
    system.stateVersion = "21.11";
    system.build = rec {
      mbr_disk_id = "888885b1";
    };

    boot.kernelPackages = kernelPackages;
    boot.loader = {
      grub.enable = false;
      systemd-boot.enable = false;
      generic-extlinux-compatible = {
        enable = true;
      };
    };

    hardware.deviceTree.name = "rockchip/rk3588-nvr-demo-v10-android.dtb";

    tow-boot = {
      enable = true;
      autoUpdate = false;
      device = "radxa-rock5b";
      config = {
        device.identifier = lib.mkForce "rockchip-rk3588-nvr-demo-v10";
        Tow-Boot = {
          defconfig = lib.mkForce "rk3588_defconfig";
          config = [
            (helpers: with helpers; {
              # DEFAULT_DEVICE_TREE = "rk3558-nvr-demo-v10-android";
            })
          ];
        };
      };
    };
  };
}
