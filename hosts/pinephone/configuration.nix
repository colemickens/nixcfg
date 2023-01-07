{ pkgs, lib, config, inputs, ... }:

{
  imports = [
    ./unfree.nix
    ./mobile-nixos-bootloader.nix

    ../../mixins/iwd-networks.nix
    ../../mixins/nix.nix
    ../../mixins/sshd.nix
    ../../mixins/tailscale.nix

    ../../profiles/user.nix

    # ../../profiles/gui-phosh.nix # tired of webkit-gtk issues
    ../../profiles/gui-wayland-sway2.nix

    (import "${inputs.mobile-nixos-pinephone}/lib/configuration.nix" {
      device = "pine64-pinephone";
    })
  ];

  config = {
    system.stateVersion = "22.05";
    networking.hostName = "pinephone";

    mobile-nixos.install-bootloader = {
      enable = true;
    };

    networking.networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };

    security.sudo.wheelNeedsPassword = false;

    documentation = {
      doc.enable = false;
      dev.enable = false;
      info.enable = false;
      nixos.enable = false;
    };

    hardware.firmware = lib.mkBefore [ config.mobile.device.firmware ];

    networking.interfaces."wlan0".useDHCP = true;

    # if we have to `mobile.enable=false` then I guess we need this?
    # fileSystems = {
    #   "/" = { fsType = "ext4"; device = "/dev/sda1"; };
    # };
    # boot.loader.grub.enable = false;
    boot.loader.systemd-boot.enable = lib.mkForce false;
    # boot.loader.generic-extlinux-compatible.enable = true;

    # mobile = {
    #   # enable = false;
    #   # boot.stage-1.enable = true;
    #   boot.stage-1.kernel.useNixOSKernel = true;
    # };
    # boot.kernelPackages = pkgs.linuxPackages_latest;

    # hardware.deviceTree.overlays = [
    #   {
    #     name = "pinephone-emmc-vccq-mod";
    #     dtsFile = ./dts-pinephone-emmc-vccq-mod.dts;
    #   }
    # ];
  };
}
