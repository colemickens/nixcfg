{ pkgs, lib, modulesPath, inputs, config, ... }:

let
  hn = "visionfivetwo1";
in
{
  imports = [
    ../../profiles/core.nix
    ../../profiles/addon-cross.nix

    # the visionfive module pulls in the nixos-riscv64 overlay automatically:
    "${inputs.nixos-riscv64}/nixos/visionfive2.nix"
  ];

  config = {
    system.stateVersion = "21.11";
    nixpkgs.overlays = [
      (final: super: {
        makeModulesClosure = x:
          super.makeModulesClosure (x // { allowMissing = true; });
      })
    ];

    nix.nixPath = [ ];
    nix.gc.automatic = true;

    /**/
    nixcfg.common.defaultKernel = false;
    # nixcfg.common.useZfs = false;
    services.fwupd.enable = lib.mkForce false;
    services.udisks2.enable = lib.mkForce false;
    hardware.usbWwan.enable = lib.mkForce false;
    /**/

    documentation.enable = false;
    documentation.doc.enable = false;
    documentation.info.enable = false;
    documentation.nixos.enable = false;

    nixpkgs.crossSystem.system = "riscv64-linux";

    environment.systemPackages = with pkgs; [
      binutils
      usbutils
    ];

    fileSystems = {
      # "/boot/firmware" = {
      #   fsType = "vfat";
      #   device = "/dev/disk/by-label/FIRMWARE";
      # };
      "/" = {
        device = "/dev/disk/by-label/NIXOS_SD";
        fsType = "ext4";
        # fsType = "zfs"; device = "tank2/root";
      };
    };

    boot = {
      loader = {
        grub.enable = false;
        systemd-boot.enable = false;
        generic-extlinux-compatible.enable = true;
        generic-extlinux-compatible.configurationLimit = 3;
      };
      tmpOnTmpfs = false;
      cleanTmpDir = true;

      kernelModules = config.boot.initrd.availableKernelModules;
    };

    # TODO: move some more of this to common?
    networking = {
      hostName = hn;
      firewall.enable = true;
      firewall.allowedTCPPorts = [ 22 ];
      networkmanager.enable = false;
    };
    services.timesyncd.enable = true;
    time.timeZone = "America/Los_Angeles";

  };
}
