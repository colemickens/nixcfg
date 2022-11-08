{ config, pkgs, lib, inputs, ... }:
let
  hn = config.networking.hostName;
  # carbon bootloader = systemd (laptop has secure boot disabled)
in
{
  imports = [
    ../../profiles/sway/default.nix
    ../../profiles/dev.nix

    # TODO: necessary with the nixosHardware imports?
    ../../mixins/gfx-radeonsi.nix
    ../../mixins/gfx-debug.nix

    ../../mixins/android.nix
    # ../../mixins/devshells.nix
    # ../../mixins/easyeffects.nix
    # no, carbon uses systemd with the extended
    # boot partition support...
    # ../../mixins/grub-signed-shim.nix
    ../../mixins/hidpi.nix
    ../../mixins/iwd.nix
    ../../mixins/ledger.nix
    ../../mixins/libvirt.nix
    ../../mixins/logitech-mouse.nix
    ../../mixins/obs.nix
    ../../mixins/plex-mpv.nix
    ../../mixins/snapclient-local.nix
    # ../../mixins/snapcast-sink.nix # doesn't work, feels like a privacy risk
    ../../mixins/sshd.nix
    ../../mixins/syncthing.nix
    ../../mixins/tailscale.nix
    ../../mixins/upower.nix
    # ../../mixins/wpa-full.nix
    ../../mixins/zfs.nix

    # ./experimental.nix
    ./unfree.nix

    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate # not until 5.19, touchpad
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
  ];

  config = {
    system.stateVersion = "21.05";
    networking.hostName = "carbon";
    
    hardware.video.hidpi.enable = true;

    nixcfg.common.hostColor = "purple";

    # TODO: attempt to fix sound, but broke alsa/pipewire:
    # environment.etc."modprobe.d/snd.conf".text = ''
    #   options snd-sof-intel-hda-common hda_model=alc287-yoga9-bass-spk-pin
    # '';

    hardware.bluetooth.enable = true;
    hardware.usbWwan.enable = true;
    hardware.cpu.amd.updateMicrocode = true;

    services.power-profiles-daemon.enable = true;
    services.fwupd.enable = true;

    powerManagement.enable = true;

    # experiments!
    # see also ./experiments.nix
    # maybe move to a specialisation:
    # stage-1 -> systemd
    # services.kmscon.enable = true;   # kmscon breaks sway!
    # services.kmscon.hwRender = true; # though maybe not if hwRender is off?

    # TODO: revisit...? Can we get S3 on this POS Lenovo Chinesium?
    # services.logind.extraConfig = ''
    #   HandlePowerKey=hybrid-sleep
    #   HandleLidSwitch=hybrid-sleep
    # '';
    # oh, these probably made things worse since it can't suspend...
    # services.logind.extraConfig = ''
    #   HandlePowerKey=suspend-then-hibernate
    #   HandleLidSwitch=suspend-then-hibernate
    # '';

    # WAIT_ONLINE DEBUG
    systemd.network.wait-online.ignoredInterfaces = lib.mkForce [ ];
    systemd.network.wait-online.anyInterface = true;
    # systemd.network.wait-online.timeout = 0;

    fileSystems = {
      "/efi" = { fsType = "vfat"; device = "/dev/nvme0n1p1"; neededForBoot = true; };
      "/boot" = { fsType = "vfat"; device = "/dev/disk/by-partlabel/${hn}-boot"; neededForBoot = true; };
      "/" = { fsType = "zfs"; device = "${hn}pool/root"; neededForBoot = true; };
      "/nix" = { fsType = "zfs"; device = "${hn}pool/nix"; neededForBoot = true; };
      "/persist" = { fsType = "zfs"; device = "${hn}pool/persist"; neededForBoot = true; };
      "/home" = { fsType = "zfs"; device = "${hn}pool/home"; neededForBoot = true; };
    };
    swapDevices = [{ device = "/dev/disk/by-partlabel/${hn}-swap"; }];
    boot = {
      loader.efi.efiSysMountPoint = "/efi";
      loader.grub.enable = false;
      loader.systemd-boot = {
        entriesMountPoint = "/boot";
        enable = true;
      };
      kernelModules = [ "iwlwifi" "ideapad_laptop" ];
      kernelParams = [
        "zfs.zfs_arc_max=${builtins.toString (1024 * 1024 * (1024 * 6))}"
        # "ideapad_laptop.allow_v4_dytc=1"
        "snd_hda_intel.model=lenovo-sky"
      ];
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
      initrd.luks.devices."nixos-luksroot" = {
        device = "/dev/disk/by-partlabel/${hn}-luksroot";
        preLVM = true;
        allowDiscards = true;
        #fallbackToPassword = true;
      };
    };
  };
}
