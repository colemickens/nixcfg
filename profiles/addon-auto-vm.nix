{ pkgs, lib, inputs, modulesPath, ... }:

{
  imports = [
    ./gui-sway-auto.nix
  ];

  config = {
    services.timesyncd.enable = lib.mkForce false;

    virtualisation = {
      qemu.options = [
        "-vga none"
        "-device virtio-vga-gl"
        "-display gtk,gl=on"
      ];
    };
  };
}
