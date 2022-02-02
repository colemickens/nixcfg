{ pkgs, lib, modulesPath, inputs, config, ... }:

let
  cfgLimit = 10;
  useGrub = false;
  useGummi = false;
  loader = if useGrub then {
    efi.canTouchEfiVariables = false;
    grub.enable = true;
    grub.devices = [ "nodev" ];
    grub.configurationLimit = cfgLimit;
    grub.efiSupport = true;
    grub.efiInstallAsRemovable = true;
    generic-extlinux-compatible.enable = false;
  } else if useGummi then {
    # TODO: test this boot variant
    grub.enable = false;
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = cfgLimit;
    generic-extlinux-compatible.enable = false;
  } else {
    grub.enable = false;
    generic-extlinux-compatible.enable = true;
    generic-extlinux-compatible.configurationLimit = cfgLimit;
  };
in
{
  imports = [
    ./core.nix
  ];

  config = {
    # TODO: backup /boot, wipe it, switch to grub, try foundation kernel with the efi boot mode
    boot.loader = loader;

    specialisation = {
      "foundation" = {
        inheritParentConfig = false;
        configuration = {
          imports = [
            ./core.nix
          ];
          config = {
            boot = {
              kernelPackages = pkgs.lib.mkForce pkgs.linuxPackages_rpi4;
              kernelPatches = [
                {
                  name = "random-fix-crash";
                  patch = ./kernel-fix-random-crash.patch;
                }
              ];
              # kernelParams = [ # when (!no ATF and) the passthru dtb, this isnt needed hm
              #   # not sure what the console is with rpi4
              # ];
            };
          };
        };
      };
    };

    boot = {
      # weird, this wrosk with extlinux+grub, even with the earlycon set like that
      kernelPackages = pkgs.lib.mkForce pkgs.linuxPackages_5_16;
      kernelParams = [ # when (!no ATF and) the passthru dtb, this isnt needed hm
        "earlycon=uart8250,mmio32,0xfe215040"
        
        "earlyprintk"
        "console=ttyS1,115200"
        "console=tty1"
        "console=ttyS0,115200"
      ];
    };
  };
}
