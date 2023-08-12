{ pkgs, lib, modulesPath, inputs, config, ... }:

{
  imports = [
    ./inner.nix
    ../../profiles/addon-cross.nix
    "${inputs.nixos-hardware}/starfive/visionfive/v2/sd-image.nix"
  ];
  config = {
    networking.hostName = lib.mkForce "vf2-sdcard";

    boot.initrd.systemd.enable = lib.mkForce false;
  };
}
