{ config, lib, pkgs, modulesPath, inputs, ... }:

let
  natDevices = {
    blueline1 = { link_match.Driver = "rndis_host"; addr = "10.0.88.1/24"; };
    enchilada1 = { link_match.MACAddress = "0a:6b:c5:7a:8b:d3"; addr = "10.0.99.1/24"; };
  };
  mk = (k: v: {
    networks."40-${k}" = {
      matchConfig.Name = k;
      addresses = [{ addressConfig.Address = v.addr; }];
      linkConfig.RequiredForOnline = false;
      DHCP = "no";
    };
    links."20-${k}" = {
      matchConfig = v.link_match;
      linkConfig.Name = k;
      linkConfig.NamePolicy = "";
    };
    links."30-catch" = {
      matchConfig.OriginalName = "*";
      linkConfig.NamePolicy = "";
    };
  });
  computed = (lib.fold lib.recursiveUpdate {} (lib.mapAttrsToList mk natDevices));
in
{
  imports = [
    ../../profiles/sway
    ../../modules/loginctl-linger.nix

    ../../mixins/loremipsum-media/rclone-mnt.nix

    ../../mixins/gfx-nvidia.nix

    ../../mixins/android.nix
    #../../mixins/code-server.nix
    ../../mixins/devshells.nix
    ../../mixins/logitech-mouse.nix
    ../../mixins/plex-mpv.nix
    ../../mixins/sshd.nix
    ../../mixins/syncthing.nix
    ../../mixins/tailscale.nix
    ../../mixins/zfs.nix

    ./qemu-cross-arch.nix
    ./grub-shim.nix
    "${inputs.hardware}/common/cpu/amd"
    "${inputs.hardware}/common/pc/ssd"
  ];

  config = {
    # it sometimes boots as a hyper-v guest, so...
    virtualisation.hypervGuest.enable = true;

    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "nvidia-x11"
      "nvidia-settings"
      "cudatoolkit"
    ];

    environment.systemPackages = with pkgs; [
      hdparm
      esphome
      mokutil
    ];

    users.users.cole.linger = true;

    boot = {
      supportedFilesystems = [ "zfs" ];
      kernelParams = [ "mitigations=off" ];
    };

    nix.nixPath = [ ];
    nix.settings.build-cores = lib.mkForce 4;

    hardware.usbWwan.enable = true;

    networking.hostName = "porty";
    networking.hostId = "abbadaba";
    networking.useDHCP = false;
    networking.useNetworkd = true;
    networking.networkmanager.enable = false;

    systemd.network =
      lib.traceValSeq (lib.recursiveUpdate computed { 
        networks."40-eno1" = {
          matchConfig.Name = "eno1";
          linkConfig.RequiredForOnline = true;
          DHCP = "yes";
        };
      });

    networking.nat = {
      enable = true;
      internalInterfaces = (builtins.attrNames natDevices);
      externalInterface = "eno1";
      internalIPs = [ "10.0.0.0/16" ];
    };

    hardware.enableRedistributableFirmware = true;
    boot.loader.grub.pcmemtest.enable = true;
    boot.initrd.availableKernelModules = [ "sd_mod" "sr_mod" ];
    boot.initrd.kernelModules = [
      "hv_vmbus"
      "hv_storvsc" # for booting under hyperv
      "xhci_pci"
      "nvme"
      "usb_storage"
      "sd_mod"
      "ehci_pci"
      "uas"
    ];

    fileSystems."/" = { fsType = "zfs"; device = "portypool/root"; };
    fileSystems."/nix" = { fsType = "zfs"; device = "portypool/nix"; };
    fileSystems."/home" = { fsType = "zfs"; device = "portypool/home"; };
    fileSystems."/boot" = { fsType = "vfat"; device = "/dev/disk/by-partlabel/porty-boot"; };

    boot.initrd.luks.devices."porty-luks" = {
      allowDiscards = true;
      device = "/dev/disk/by-partlabel/porty-luks";

      keyFile = "/lukskey";
      fallbackToPassword = true;
    };
    boot.initrd.secrets = {
      "/lukskey" = pkgs.writeText "lukskey" "test";
    };

    swapDevices = [ ];

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "21.05"; # Did you read the comment?

    services.fwupd.enable = true;
  };
}
