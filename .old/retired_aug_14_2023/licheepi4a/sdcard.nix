{ pkgs, lib, modulesPath, inputs, config, ... }:

{
  imports = [
    ./inner.nix
    ../../profiles/addon-cross.nix
    "${inputs.nixos-licheepi4a}/modules/sd-image/sd-image-lp4a.nix"
  ];
  config = {
    networking.hostName = lib.mkForce "licheepi4a-sdcard";

    boot.initrd.systemd.enable = lib.mkForce false;
  };
}
