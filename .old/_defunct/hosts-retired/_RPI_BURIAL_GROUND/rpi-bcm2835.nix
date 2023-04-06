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

    # tow-boot.config = {
    #   rpi = {
    #     upstream_kernel = false;
    #   };
    # };

    nixpkgs.overlays = [
      (final: prev: {
        btrfs-progs = prev.runCommand "foo" { } ''
          mkdir -p $out/share/
          touch $out/share/btrfs-progs.txt
        '';
        makeModulesClosure = x: prev.makeModulesClosure (x // { allowMissing = true; });
      })
    ];

    # cross-build compatibility
    security.polkit.enable = false;
    services.udisks2.enable = lib.mkForce false;
    boot.enableContainers = false;
    programs.command-not-found.enable = false;
    environment.noXlibs = true;

    boot = {
      kernelParams = [
        # when (!no ATF and) the passthru dtb, this isnt needed hm
        "earlyprintk"
        # maybe breaks (1/2): "earlycon=uart8250,mmio32,0x3f215040"
        # maybe breaks (2/2): "console=ttyS1,115200"
      ];
      # historically our rpizero*s have used the generation tree, so lets keep that for now
      # loader.generic-extlinux-compatible = {
      #   useGenerationDeviceTree = false;
      # };
    };

    fileSystems = lib.mkDefault { };
  };
}
