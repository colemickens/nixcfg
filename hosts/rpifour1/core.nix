{ pkgs, modulesPath, inputs, config, ... }:
let
  towbootBuild = import "${inputs.tow-boot}/support/nix/eval-with-configuration.nix" {
    pkgs = pkgs;
    device = "raspberryPi-aarch64";
    configuration = ({lib,config,...}: {
      system.automaticCross = lib.mkForce false;
      nixpkgs.system = "aarch64-linux";
    });
  };
  _towbootUpdate = towbootBuild.config.Tow-Boot.outputs.scripts;

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

    ../../mixins/wpasupplicant.nix
  ];

  #
  # sudo env \
  #   BOOTFS=/boot/firmware \
  #   FIRMWARE_RELEASE_STATUS=stable \
  #     rpi-eeprom-config --edit
  #

  config = {
    system.stateVersion = "21.05";
    environment.systemPackages = with pkgs; [
      _towbootUpdate
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

    boot.tmpOnTmpfs = false; # low mem device
    boot = {
      loader = loader;
      initrd.availableKernelModules = [
        "pcie_brcmstb" "bcm_phy_lib" "broadcom" "mdio_bcm_unimac" "genet"
        "vc4" "bcm2835_dma" "i2c_bcm2835"
        "reset_raspberrypi" # needed for USB reset, so that USB works in kernel 5.14
        "xhci_pci" "nvme" "usbhid" "usb_storage" "sd_mod"
        "uas" # necessary for my UAS-enabled NVME-USB adapter
      ];
      kernelModules = config.boot.initrd.availableKernelModules;
    };
  };
}
