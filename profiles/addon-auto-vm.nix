{ pkgs, lib, inputs, modulesPath, ... }:

{
  imports = [
    ./gui-sway-auto.nix
  ];

  config = {
    virtualisation = {
      qemu.options = [
        "-vga none"
        "-device virtio-vga-gl"
        "-display gtk,gl=on"
      ];
    };
  };
}
