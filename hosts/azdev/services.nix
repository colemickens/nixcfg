{ config, pkgs, inputs, ... }:

let arm6vm = {
  system = "armv6l-linux";
  cpu = ""; # leave to default behavior of the machine
  machine = "raspi0";
  #mem = "8g";
  mem = "512M";
  smp = 1;
  kvm = false;

  # instead of overriding config, make it so we can override the core pkgs
  # used, it must be for "both sides", meaning the eval-config must be the
  # the same as the one used to build the system.
  config = { config, pkgs, ... }: {
    # override the pkgs directly
    # to one that might work for crossSystem build:
    config.boot.kernelPackages = pkgs.lib.mkForce pkgs.linuxPackages_rpi1;
    config.boot.initrd.availableKernelModules = pkgs.lib.mkForce [ "virtio_net" "virtio_mmio" "virtio_blk" "virtio_scsi" "9p" "9pnet_virtio" ];
    config.nixpkgs.pkgs = import "${inputs.cross-pkgs}" {
      system = "x86_64-linux";
      crossSystem =
        (import "${inputs.nixpkgs}/lib").systems.examples.raspberryPi;
    };
  };
}; in {
  imports = [
    ../../mixins/buildkite-agent.nix
  ];

  config = {
    services.buildVMs = {
      "armv6l-cross" = arm6vm;
    };
  };
}
