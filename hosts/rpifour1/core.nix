{ pkgs, modulesPath, inputs, config, ... }:
let
  tbEval = "${inputs.tow-boot}/support/nix/eval-with-configuration.nix";
  tbPi = import tbEval {
    pkgs = pkgs;
    device = "raspberryPi-aarch64";
    configuration = ({lib,config,...}: {
      system.automaticCross = lib.mkForce false;
      nixpkgs.system = "aarch64-linux";
    });
  };
  tbPiPkg = tbPi.config.Tow-Boot.outputs.scripts;

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
    ../../profiles/interactive.nix

    ../../mixins/sshd.nix
    ../../mixins/tailscale.nix

    ./wifi.nix
  ];

  #
  # sudo env \
  #   BOOTFS=/boot/firmware \
  #   FIRMWARE_RELEASE_STATUS=stable \
  #     rpi-eeprom-config --edit
  #

  config = {
    system.stateVersion = "21.05";

    nix.nixPath = [];
    nix.gc.automatic = true;

    documentation.enable = false;
    documentation.doc.enable = false;
    documentation.info.enable = false;
    documentation.nixos.enable = false;

    environment.systemPackages = with pkgs; [
      raspberrypifw
      raspberrypi-eeprom
      libraspberrypi

      binutils
      usbutils

      tbPiPkg
    ];

    specialisation = {
      "foundation" = {
        inheritParentConfig = true;
        configuration = {
          config = {
            boot.kernelPackages = pkgs.lib.mkForce pkgs.linuxPackages_rpi4;
          };
        };
      };
    };

    boot = {
      loader = loader;
      tmpOnTmpfs = false;
      cleanTmpDir = true;

      initrd.availableKernelModules = [
        "pcie_brcmstb" "bcm_phy_lib" "broadcom" "mdio_bcm_unimac" "genet"
        "vc4" "bcm2835_dma" "i2c_bcm2835"
        "reset_raspberrypi" # needed for USB reset, so that USB works in kernel 5.14
        "xhci_pci" "nvme" "usbhid" "usb_storage" "sd_mod"
        "uas" # necessary for my UAS-enabled NVME-USB adapter
      ];
      kernelModules = config.boot.initrd.availableKernelModules;
    };

    networking = {
      firewall.enable = true;
      firewall.allowedTCPPorts = [ 22 ];
      networkmanager.enable = false;
    };
    services.timesyncd.enable = true;
    time.timeZone = "America/Los_Angeles";

    hardware.enableRedistributableFirmware = false;
  };
}
