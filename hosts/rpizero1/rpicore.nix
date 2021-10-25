{ pkgs, lib, modulesPath, inputs, config, ... }:

{
  imports = [
    ../../mixins/common.nix
    ../../profiles/user.nix

    ../../mixins/sshd.nix
    ../../mixins/tailscale.nix

    # TODO: still not working, it doesn't actually stop "loading" often times? wtf, or is that my restart wait?
    ../../modules/tailscale-autoconnect.nix
  ];

  config = {
    fileSystems."/boot/firmware" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
      options = [ "ro" "nofail" ];
    };

    services.tailscale-autoconnect.enable = true;
    services.tailscale-autoconnect.tokenFile = "/tailscale-key.txt";

    system.stateVersion = "21.05";
    environment.systemPackages = with pkgs; [
      libraspberrypi # what's in here again?
      raspberrypi-eeprom # ? for updating eeprom?
    ];

    nix.nixPath = [];
    nix.gc.automatic = true;

    # force cross-compilation by includer
    nixpkgs.crossSystem = null;

    documentation.enable = false;
    documentation.doc.enable = false;
    documentation.info.enable = false;
    documentation.nixos.enable = false;

    security.polkit.enable = false;
    services.udisks2.enable = false;
    boot.enableContainers = false;
    programs.command-not-found.enable = false;
    environment.noXlibs = true;

    # TODO: cole... why do you not understadn the diff here? why does this not get crossed the other way, I must be using the wrong thing everywhere i do pkgs.system
    #nix.package = lib.mkForce inputs.self.outputs.nixPkgs?;
    nix.package = lib.mkForce pkgs.nixUnstable;
  
    boot.initrd.kernelModules = [ "vc4" "bcm2835_dma" "i2c_bcm2835" ];
    boot.initrd.availableKernelModules = lib.mkForce [
      "mmc_block"
      "usbhid"
      "hid_generic"
      "hid_microsoft"
    ];

    boot = {
      tmpOnTmpfs = false;
      cleanTmpDir = true;

      loader.grub.enable = false;
      loader.generic-extlinux-compatible.enable = true;
      loader.raspberryPi = {
        enable = true;
        uboot.enable = true;
        version = null;
      };
    };

    networking = {
      #hostName = null;
      firewall.enable = true;
      firewall.allowedTCPPorts = [ 22 ];
      wireless.enable = true;
      useDHCP = true;
      #networkmanager.enable = true;
    };

    nixpkgs.config.allowUnfree = true;
    hardware = {
      # this pulls in firmware-nonfree which clashes with raspberrypiWirelessFirmware
      enableRedistributableFirmware = lib.mkForce false;
      firmware = with pkgs; [
        raspberrypiWirelessFirmware
      ];
    };
  };
}
