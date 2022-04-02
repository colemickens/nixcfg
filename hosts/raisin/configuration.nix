{ config, pkgs, lib, inputs, ... }:
let
  hostname = "raisin";
  hn = config.networking.hostName;
in
{
  imports = [
    ../../profiles/sway/default.nix

    # TODO: necessary with the nixosHardware imports?
    ../../mixins/gfx-radeonsi.nix
    ../../mixins/gfx-debug.nix

    ../../mixins/devshells.nix
    ../../mixins/grub-signed-shim.nix
    ../../mixins/hidpi.nix
    ../../mixins/ledger.nix
    ../../mixins/libvirt.nix
    ../../mixins/logitech-mouse.nix
    ../../mixins/sshd.nix
    ../../mixins/syncthing.nix
    ../../mixins/tailscale.nix
    ../../mixins/upower.nix
    ../../mixins/wpasupplicant.nix
    ../../mixins/zfs.nix

    ./unfree.nix
      
    ../../modules/ttys.nix

    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-gpu-amd
    inputs.hardware.nixosModules.common-pc-laptop-ssd
  ];

  config = {
    # TODO: maybe move to common?
    services.ttys = {
      unsafe_enable = true;
      vts = {
        tty1 = {
          ttyType = "getty";
          getty.autologinUser = "cole";
        };
        # tty2 (will default to getty, with getty = { similar opts/defaults as getty module })
        tty3 = {
          ttyType = "kmscon";
          kmscon.drm = false;
          kmscon.hwaccel = false;
        };
        tty4 = {
          ttyType = "kmscon";
          kmscon.drm = true;
          kmscon.hwaccel = false;
        };
        tty5 = {
          ttyType = "kmscon";
          kmscon.drm = true;
          kmscon.hwaccel = true;
        };
        # tty6 is, by default, logind's ReservedVT (however, we run the unit for it)
        # TODO: the module should assert that "${config.services.logind.reservedVT}" is not set by the user
      };
    };



    system.stateVersion = "21.05";
    networking.hostName = hostname;

    hardware.bluetooth.enable = true;
    hardware.usbWwan.enable = true;

    nix.settings.max-jobs = 8;

    services.tlp.enable = true;
    services.fwupd.enable = true;
    # services.kmscon.enable = true;   # kmscon breaks sway!
    # services.kmscon.hwRender = true; # though maybe not if hwRender is off?
    services.logind.extraConfig = ''
      HandlePowerKey=hybrid-sleep
    '';

    fileSystems = {
      "/boot" = { fsType = "vfat"; device = "/dev/disk/by-partlabel/${hn}-boot"; neededForBoot = true; };
      "/" = { fsType = "zfs"; device = "${hn}pool/root"; neededForBoot = true; };
      "/nix" = { fsType = "zfs"; device = "${hn}pool/nix"; neededForBoot = true; };
      "/backup" = { fsType = "zfs"; device = "${hn}pool/backup"; neededForBoot = true; };
      "/home" = { fsType = "zfs"; device = "${hn}pool/home"; neededForBoot = true; };
    };
    swapDevices = [{ device = "/dev/disk/by-partlabel/swap"; }];
    boot = {
      plymouth.enable = true;
      # TODO:  plymouth.font = "${config.nixcfg.appearance.fonts.monospaced.package}/share/fonts/truetype/Iosevka.ttf";
      kernelModules = [ "iwlwifi" "ideapad_laptop" ];
      initrd.availableKernelModules = [
        "xhci_pci"
        "xhci_hcd" # usb
        "nvme"
        "usb_storage"
        "sd_mod" # nvme / external usb storage
        "rtsx_pci_sdmmc" # sdcard
        "intel_agp"
        "usbnet"
      ];
      initrd.luks.devices."${hn}-luksroot" = {
        name = "${hn}-luksroot";
        device = "/dev/disk/by-partlabel/${hn}-luksroot";
        preLVM = true;
        allowDiscards = true;
        #fallbackToPassword = true;
      };
    };
  };
}
