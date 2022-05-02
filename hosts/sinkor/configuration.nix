{ pkgs, lib, modulesPath, inputs, config, ... }:
let
  hostname = "sinkor";
in
{
  imports = [
    ../../profiles/interactive.nix # linger + secrets
    ../../mixins/syncthing.nix
    ../../mixins/wpa-full.nix

    # TODO: adopt this on all machines, move to common
    inputs.impermanence.nixosModules.impermanence
  ];

  config = {
    system.stateVersion = "21.05";
    networking.hostName = hostname;
    time.timeZone = "America/Chicago";

    nix.gc.randomizedDelaySec = "600"; # just don't run right at boot (impermanence)

    # impermance system-wide
    environment.persistence."/persist" = {
      directories = [
        "/var/log"
        "/var/lib/tailscale"
        # "/var/lib/bluetooth"
        # "/var/lib/systemd" # timers, rfkill state, etc
        # "/etc/NetworkManager/system-connections"
      ];
      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
      ];
    };
    # impermance user-wide
    programs.fuse.userAllowOther = true;
    systemd.tmpfiles.rules = [
      "d /persist/home/cole 0750 cole cole - -"

      # rfkill
      # "f+ /var/lib/systemd/rfkill/platform-fe300000.mmcnr:wlan 0755 root root - 1"
    ];
    home-manager.users.cole = { pkgs, ... }: {
      systemd.user.startServices = "sd-switch";
      imports = [
        "${inputs.impermanence}/home-manager.nix"
      ];
      home.persistence."/persist/home/cole" = {
        directories = [
          "Syncthing"
          # "Music"
          # "Pictures"
          # "Documents"
          # "Videos"
          # "VirtualBox VMs"
          # ".gnupg"
          ".ssh"
          # ".nixops"
          # ".local/share/keyrings"
          # ".local/share/direnv"
          ".config/syncthing"
        ];
        files = [
          # ".screenrc"
        ];
        allowOther = true;
      };
    };

    boot = {
      # TOW_BOOT + GRUB
      # (works, but hangs for a long time between grub -> kernel booting)
      loader.efi.canTouchEfiVariables = false;
      loader.grub = {
        enable = true;
        efiSupport = true;
        efiInstallAsRemovable = true;
        device = "nodev";
        configurationLimit = 3;
      };
      kernelParams = [ "console=ttyS0,115200n8" "console=tty1" ]; # some msgs come through? (errors, but not the stage1 messages, etc)
      # console doesn't work once linux starts booting?
      # but I think it did with extlinux, must be yet another difference?

      # TOW_BOOT + EXTLINUX
      # (wrong console, no luks prompt, doesn't take my kb input)
      # loader.efi.canTouchEfiVariables = false;
      # loader.grub.enable = false;
      # loader.generic-extlinux-compatible.enable = true;

      tmpOnTmpfs = false;
      cleanTmpDir = true;

      zfs.enableUnstable = true;
      initrd.availableKernelModules = [
        "pcie_brcmstb" "bcm_phy_lib" "broadcom" "mdio_bcm_unimac" "genet"
        "vc4" "bcm2835_dma" "i2c_bcm2835"
        "reset_raspberrypi" # needed for USB reset, so that USB works in kernel 5.14
        "xhci_pci" "nvme" "usbhid" "usb_storage" "sd_mod"
        "uas" # necessary for my UAS-enabled NVME-USB adapter

        "xchacha12" "adiantum" "nhpoly1305" "libpoly1305" "libchacha"
      ];
      kernelModules = config.boot.initrd.availableKernelModules;

      initrd.supportedFilesystems = [ "zfs" ];
      supportedFilesystems = [ "zfs" ];
    };

    # TODO: snapshot whatever was written from last run
    # TODO: can we do that pre-emptively on shutdown instead?
    # TODO: move to impermanence module
    boot.initrd.postDeviceCommands = lib.mkAfter ''
      zfs rollback -r sinkortank/root@blank
    '';

    boot.initrd.luks = {
      devices = {
        "sinkor-zfs" = {
          name = "sinkor-zfs";
          device = "/dev/disk/by-id/usb-WD_Elements_25A3_5758333244353146395A5546-0:0";
          preLVM = true;

          #keyFileSize = 4096;
          keyFile = "/lukskey";
          header = "/dev/disk/by-id/mmc-SH64G_0x548598bb-part3";
          fallbackToPassword = true;
        };
      };
    };

    boot.initrd.secrets = {
      "/lukskey" = pkgs.writeText "lukskey" "test";
    };

    fileSystems = {
      # on the tow-boot SD card
      "/boot" = {
        device = "/dev/disk/by-id/mmc-SH64G_0x548598bb-part2";
        fsType = "vfat";
        options = [ "nofail" ];
      };
      # tow-boot firmware
      "/firmware" = {
        device = "/dev/disk/by-id/mmc-SH64G_0x548598bb-part1";
        fsType = "vfat";
        options = [ "nofail" "ro" ];
      };

      # on the spinning rust backup HDD
      "/" = {
        # TODO: should we snapshot and revert this on boot, like grahamc's darlings?
        device = "sinkortank/root";
        fsType = "zfs";
      };
      "/nix" = {
        device = "sinkortank/nix";
        fsType = "zfs";
      };
      "/persist" = {
        # TODO: future: backed up with zrepl to rsync.net?
        device = "sinkortank/persist";
        fsType = "zfs";
        neededForBoot = true; # for impermanence
      };
    };
  };
}
