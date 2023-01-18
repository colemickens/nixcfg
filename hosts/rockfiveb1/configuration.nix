{ pkgs, lib, modulesPath, inputs, config, extendModules, ... }:

let
  # eth_ip = "192.168.162.69/16";
  kernel = pkgs.callPackage ./kernel.nix { };
  kernelPackages = pkgs.linuxKernel.packagesFor kernel;
  hn = "rockfiveb1";
in
{
  imports = [
    ../../profiles/core.nix
    ../../profiles/gui-wayland-hyprland.nix

    ../../modules/rsynstall.nix

    ../../mixins/iwd-networks.nix

    ./unfree.nix

    inputs.tow-boot-radxa-rock5b.nixosModules.default
  ];
  config = {
    nixpkgs.hostPlatform.system = "aarch64-linux";

    environment.systemPackages = with pkgs; [
      xdg-desktop-portal-hyprland
    ];
    nixpkgs.overlays = [
      inputs.hyprland.overlays.default
      (final: super: {
        makeModulesClosure = x:
          super.makeModulesClosure (x // { allowMissing = true; });
      })
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
      # defaultNetworking = false;
      sysdBoot = false;
    };
    networking.wireless.iwd.enable = true;

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

    # configuration.config.Tow-Boot = {
    tow-boot = {
      enable = true;
      autoUpdate = false;
      device = "radxa-rock5b";
      config = {
        device.identifier = "radxa-rock5b";
        Tow-Boot = {
          defconfig = "rock-5b-rk3588_defconfig";
        };
      };
    };
  };
}
