{ pkgs, lib, modulesPath, inputs, config, ... }:

{
  imports = [
    ./inner.nix
    ../../profiles/addon-cross.nix
    ../../profiles/addon-netboot-thin.nix
  ];
  config = {
    networking.hostName = lib.mkForce "lipi4a-netboot";
    boot.loader.timeout = lib.mkForce 10;

    # boot.initrd.systemd.network.enable = true;
    # boot.initrd.systemd.network.config =
    #   config.systemd.network.config;
    boot.initrd.systemd.network =
      config.systemd.network;

    boot.initrd.systemd.emergencyAccess = true;

    netboot.enable = true;
    netboot.squashfsCompression = "gzip";
    netboot.nix-store-rw.enable = false;

    services.tailscale.enable = lib.mkForce false;
  };
}
