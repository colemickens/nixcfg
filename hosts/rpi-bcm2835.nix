{ pkgs, lib, modulesPath, inputs, config, ... }:

# from: https://www.raspberrypi.com/documentation/computers/processors.html
#   The BCM2835 is the Broadcom chip used in the Raspberry Pi 1 Models A, A+,
#   B, B+, the Raspberry Pi Zero, the Raspberry Pi Zero W, and the Raspberry
#   Pi Compute Module 1.

## RPI0W

{
  imports = [
    ./rpi-core.nix
  ];

  config = {
    nixpkgs.crossSystem = lib.mkForce lib.systems.examples.raspberryPi;

    nixpkgs.overlays = [
      (final: prev: {
        btrfs-progs = prev.runCommandNoCC "foo" { } ''
          touch $out
        '';
        makeModulesClosure = x: prev.makeModulesClosure (x // { allowMissing = true; });
      })
    ];

    nixcfg.common.useZfs = false;

    # cross-build compatibility
    security.polkit.enable = false;
    services.udisks2.enable = lib.mkForce false;
    boot.enableContainers = false;
    programs.command-not-found.enable = false;
    environment.noXlibs = true;

    boot = {
      kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
      kernelParams = [
        # when (!no ATF and) the passthru dtb, this isnt needed hm
        "earlyprintk"
        "earlycon=uart8250,mmio32,0x3f215040"
        "console=ttyS1,115200"
      ];
      # historically our rpizero*s have used the generation tree, so lets keep that for now
      # loader.generic-extlinux-compatible = {
      #   useGenerationDeviceTree = false;
      # };
    };

    # TODO: harmonize filesystems (rpizero1,rpizero2), move them here??
    fileSystems = lib.mkDefault { };
  };
}
