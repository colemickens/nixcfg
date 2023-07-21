{ pkgs, lib, modulesPath, inputs, config, ... }:

{
  imports = [
    ./inner.nix
    ../../profiles/addon-cross.nix
    "${inputs.nixos-hardware}/sipeed/lipi4a/sd-image.nix"
  ];
  config = {
    networking.hostName = lib.mkForce "lipi4a-sdcard";

    boot.initrd.systemd.enable = lib.mkForce false;
  };
}
