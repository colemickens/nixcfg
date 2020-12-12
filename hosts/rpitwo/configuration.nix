{ pkgs, lib, modulesPath, inputs, ... }:

let
  hostname = "rpitwo";
    bootOrder="0xf41"; # sd, usbMSD, restart

  configtxt = pkgs.writeText "config.txt" ''
    [all]
    BOOT_UART=0
    WAKE_ON_GPIO=1
    POWER_OFF_ON_HALT=0
    DHCP_TIMEOUT=45000
    DHCP_REQ_TIMEOUT=4000
    TFTP_FILE_TIMEOUT=30000
    ENABLE_SELF_UPDATE=1
    DISABLE_HDMI=0
    BOOT_ORDER=${bootOrder}
    TFTP_PREFIX=0

    [pi4]
    arm_64bit=1
    kernel=u-boot-rpi4.bin
    enable_gic=1
    armstub=armstub8-gic.bin
  '';

  uefi_dir_with_update = pkgs.runCommandNoCC "build-tftp-rpitwo" {} ''
    (
      set -x
      mkdir -p $out/

      cp -r "${pkgs.rpi4-uefi}/boot"/. $out/

      # TODO Move some of this stuff to a "rpi-eeprom-sane" package
      # TODO "raspberrypi-eeprom{,-sane,-tools}"
      cp ${pkgs.raspberrypi-eeprom}/stable/vl805-latest.bin $out/vl805.bin
      sha256sum $out/vl805.bin | cut -d' ' -f1 > $out/vl805.sig

      cp ${pkgs.raspberrypi-eeprom}/stable/pieeprom-latest.bin $out/pieeprom.orig.bin
      ${pkgs.raspberrypi-eeprom}/bin/rpi-eeprom-config \
        --out $out/pieeprom.upd \
        --config ${configtxt} \
        $out/pieeprom.orig.bin
      sha256sum $out/pieeprom.upd | cut -d' ' -f1 > $out/pieeprom.sig

      # TODO: do the same with the vl805.bin firmware?
      # TODO: auto-script to make sure our own firmware is updated?
      # TODO: this can take out an entire cluster if a bad update were pushed
    )
  '';
in {
  imports = [
    "${modulesPath}/installer/cd-dvd/sd-image-aarch64.nix"
    ../../mixins/common.nix
    ../../mixins/sshd.nix

    ../../profiles/user.nix
  ];
  config = {
    environment.systemPackages = with pkgs; [
      raspberrypifw
      raspberrypi-eeprom
      raspberrypi-tools

      dnsutils
    ];

    # nixpkgs.overlays = [
    #   (old: pkgs: {
    #     mesa = pkgs.mesa-git; # mesa-20.3 for the new vulkan rpi4 changes
    #   })
    # ];

    # TODO, why can root ssh?

    nix.nixPath = [];
    documentation.enable = false;
    documentation.nixos.enable = false;
    networking.hostName = hostname;
    services.udisks2.enable = false;

    networking.wireless.enable = false;
    networking.interfaces."eth0".ipv4.addresses = [
      {
        address = "192.168.1.3";
        prefixLength = 16;
      }
    ];
    networking.defaultGateway = "192.168.1.1";
    networking.nameservers = [ "192.168.1.1" ];
    networking.useDHCP = false;
    networking.firewall.enable = true;

    boot.kernelPackages = pkgs.lib.mkForce pkgs.linuxPackages_5_10;
    # boot.loader.raspberrypi.rpi4uefi.enable = true;
    # boot.loader.raspberrypi.rpi4uefi.includeFirmwareUpdate = true;
    # boot.loader.raspberrypi.rpi4uefi.configTxt = ''
    #   [all]
    #   BOOT_UART=0
    #   WAKE_ON_GPIO=1
    #   POWER_OFF_ON_HALT=0
    #   DHCP_TIMEOUT=45000
    #   DHCP_REQ_TIMEOUT=4000
    #   TFTP_FILE_TIMEOUT=30000
    #   ENABLE_SELF_UPDATE=1
    #   DISABLE_HDMI=0
    #   BOOT_ORDER=${bootOrder}
    #   TFTP_PREFIX=0

    #   [pi4]
    #   arm_64bit=1
    #   kernel=u-boot-rpi4.bin
    #   enable_gic=1
    #   armstub=armstub8-gic.bin
    # '';

    boot.initrd.availableKernelModules = [ "xhci_pci" "usb_storage" ];
    boot.kernelModules = [ "xhci_pci" "usb_storage" ];
 
    boot.consoleLogLevel = lib.mkDefault 7;
  };
}