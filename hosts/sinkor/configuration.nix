{ pkgs, lib, modulesPath, inputs, config, ... }:
let
  hostname = "sinkor";
in
{
  imports = [
    ../../modules/loginctl-linger.nix

    ../../mixins/syncthing.nix
    ../../mixins/tailscale.nix
    ../../mixins/common.nix
    ../../mixins/sshd.nix

    ../../profiles/core.nix
    ../../profiles/user.nix
    
    inputs.impermanence.nixosModules.impermanence
  ];

  config = {
    # impermance system-wide
    environment.persistence."/persist" = {
      directories = [
        "/var/log"
        # "/var/lib/bluetooth"
        # "/var/lib/systemd/coredump"
        # "/etc/NetworkManager/system-connections"
      ];
      files = [
        # "/etc/machine-id"
        # "/etc/nix/id_rsa"
      ];
    };
    # impermance user-wide
    programs.fuse.userAllowOther = true;

    home-manager.users.cole = { pkgs, ... }: {
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
          # ".ssh"
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

    system.stateVersion = "21.05";
    users.users.cole.linger = true;

    nix.nixPath = [];
    nix.gc.automatic = true;

    documentation.enable = false;
    documentation.doc.enable = false;
    documentation.info.enable = false;
    documentation.nixos.enable = false;

    environment.systemPackages = with pkgs; [
      raspberrypifw
      raspberrypi-eeprom
      efibootmgr
    ];

    boot = {
      # Tow-Boot
      loader.efi.canTouchEfiVariables = false;

      # idk, can't seem to get it to install to default location
      # maybe because efibootmgr call (likely?) fails
      # loader.systemd-boot = {
      #  enable = true;
      #  configurationLimit = 5;
      # };

      loader.grub = {
       efiSupport = true;
       efiInstallAsRemovable = true;
       device = "nodev";
       configurationLimit = 5;
      };

      tmpOnTmpfs = false;
      cleanTmpDir = true;

      #kernelPackages = pkgs.lib.mkForce pkgs.linuxPackages_latest;
      kernelPackages = pkgs.lib.mkForce pkgs.linuxPackages_5_13;

      initrd.availableKernelModules = [
        "pcie_brcmstb" "bcm_phy_lib" "broadcom" "mdio_bcm_unimac" "genet"
        "vc4" "bcm2835_dma" "i2c_bcm2835"
        "xhci_pci" "nvme" "usb_storage" "sd_mod"
        "uas" # necessary for my UAS-enabled NVME-USB adapter
      ];
      kernelModules = config.boot.initrd.availableKernelModules;

      initrd.supportedFilesystems = [ "zfs" ];
      supportedFilesystems = [ "zfs" ];
    };

    networking = {
      hostId = "deadbead";
      hostName = hostname;
      firewall.enable = true;
      networkmanager.enable = true;
      wireless.enable = false;
      wireless.iwd.enable = false;
      useDHCP = false;
    };
    time.timeZone = "America/Chicago";

    nixpkgs.config.allowUnfree = true;
    hardware = {
      enableRedistributableFirmware = true;
    };

    # TODO: declarative wifi for Mickens + MickPetrey wifi networks

    # TODO: snapshot whatever was written from last run
    # TODO: can we do that pre-emptively on shutdown instead?
    boot.initrd.postDeviceCommands = lib.mkAfter ''
      echo zfs snapshot sinkortank/root@$(date '+%s')
      echo zfs rollback -r sinkortank/root@blank
    '';

    boot.initrd.luks.devices = {
      "sinkor-zfs" = {
        name = "sinkor-zfs";
        device = "/dev/disk/by-id/usb-WD_My_Passport_260F_575837324441305052353944-0:0";
        preLVM = true;
        fallbackToPassword = true;
      };
    };

    # boot.initrd.network.enable = true;
    # boot.initrd.network.ssh = {
    #   enable = true;
    #   port = 22;
    #   authorizedKeys = (import ../../data/sshkeys.nix);
    #   hostKeys = [ ./ssh_host_ed25519_key ];
    # };

    fileSystems = {
      # on the tow-boot SD card
      "/boot" = {
        device = "/dev/disk/by-partlabel/sinkor-boot";
        fsType = "vfat";
        options = [ "nofail" ];
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
