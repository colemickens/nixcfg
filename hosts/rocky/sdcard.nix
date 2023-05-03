{ pkgs, lib, modulesPath, inputs, config, ... }:

{
  imports = [
    ./inner.nix
    ../../profiles/addon-cross.nix
    # TODO: fixup this:
    "${modulesPath}/installer/sd-card/sd-image.nix"
  ];
  config = {
    networking.hostName = lib.mkForce "rocky-sdcard";

    boot.initrd.systemd.enable = lib.mkForce false;
  };
}
