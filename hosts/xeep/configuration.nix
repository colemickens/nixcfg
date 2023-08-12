{ config, pkgs, lib, inputs, ... }:

let
  hn = "xeep";
  poolname = "xeeppool";
  bootpart = "xeep-boot";
  lukspart = "xeep-luks";

  static_ip = "192.168.70.20/16";

  nb = n: inputs.self.outputs.nixosConfigurations."${n}-netboot".config.system.build;
  lipi4a = inputs.self.outputs.nixosConfigurations.lipi4a.config.system;

  # enableNetboot = true;
  enableNetboot = false;
  nbhost = "h96";
in
{
  imports = [
    ../../profiles/interactive.nix
    ../../profiles/addon-laptop.nix

    ../../mixins/iwd-networks.nix
    ../../mixins/plex.nix
    ../../mixins/syncthing.nix

    ../../mixins/gfx-intel.nix

    ../../modules/nadache.nix

    inputs.nixos-hardware.nixosModules.dell-xps-13-9370

    ./unfree.nix
  ];

  config = {
    services.nadache.enable = true;
    # TEMP START TO FIX vf2 via netboot
    services.atftpd = lib.mkIf (enableNetboot) {
      enable = true;
      extraOptions = [ "--verbose=7" ];
      # root = (pkgs.runCommand "atftpd-root" { } ''
      #   mkdir $out
      #   ln -s ${lipi4a.initrd} $out/initrd
      #   ln -s ${lipi4a.kernel}/Image $out/kernel
      #   ln -s ${lipi4a.kernel}/dtbs/sipeed/sipeed-licheepi4a.dtb $out/dtb
      #   printf "%s " "init=${lipi4a.toplevel.outPath}/init" > "$out/bootargs"
      #   cat "${lipi4a.toplevel}/kernel-params" >> "$out/bootargs"
      # '').outPath;
      # cp -r "${vf2.netbootIpxeScript}" $out/ipxe
      # root = (pkgs.runCommand "atftpd-root" { } ''
      #   mkdir $out
      #   ln -s ${(nb nbhost).initrd} $out/initrd
      #   ln -s ${(nb nbhost).kernel}/Image $out/kernel
      #   ln -s ${(nb nbhost).kernel}/dtbs/rockchip/evb-rk3588.dtb $out/dtb
      # '').outPath;
    };
    services.nginx = lib.mkIf (enableNetboot) {
      enable = true;
      virtualHosts."default" = {
        root = (pkgs.runCommand "nginx-root" { } ''
          mkdir $out
          ln -s "${(nb nbhost).squashfs}" "$out/${nbhost}-netboot-squashfs"
        '').outPath;
        extraConfig = ''
          disable_symlinks off;
        '';
      };
    };
    # TODO: this isn't enough to get atftpd working...
    networking.firewall.allowedTCPPorts = lib.mkIf (enableNetboot) [ 80 8099 ];
    networking.firewall.allowedUDPPorts = lib.mkIf (enableNetboot) [ 67 69 4011 1758 ];
    # TEMP END

    nixpkgs.hostPlatform.system = "x86_64-linux";
    system.stateVersion = "21.05";

    networking.hostName = hn;
    nixcfg.common.hostColor = "yellow";

    environment.systemPackages = with pkgs; [
      libsmbios # ? can't remember it
    ];

    services.zfs.autoScrub.pools = [ poolname ];

    services.tailscale.useRoutingFeatures = "server";

    systemd.network = {
      enable = true;
      networks."15-eth0-static-ip" = {
        matchConfig.Driver = "r8152";
        addresses = [{ addressConfig = { Address = static_ip; }; }];
        networkConfig = {
          Gateway = "192.168.1.1";
          DHCP = "no";
        };
      };
    };

    fileSystems = {
      "/" = { fsType = "zfs"; device = "${poolname}/root"; };
      "/nix" = { fsType = "zfs"; device = "${poolname}/nix"; };
      "/home" = { fsType = "zfs"; device = "${poolname}/home"; };
      "/boot" = { fsType = "vfat"; device = "/dev/disk/by-partlabel/${bootpart}"; };
    };
    swapDevices = [ ];

    boot = {
      loader.systemd-boot.enable = true;
      loader.efi.efiSysMountPoint = "/boot";
      initrd.availableKernelModules = [
        "xhci_pci"
        "xhci_hcd" # usb
        "nvme"
        "usb_storage"
        "sd_mod" # nvme / external usb storage
        "rtsx_pci_sdmmc" # sdcard
        "intel_agp"
        "i915" # intel integrated graphics
        "usbnet"
        "r8152" # usb ethernet adapter
        "msr"
      ];
      kernelModules = config.boot.initrd.availableKernelModules;
      kernelParams = [
        "zfs.zfs_arc_max=${builtins.toString (1024 * 1024 * 2048)}"
      ];
      initrd.luks.devices = {
        "nixos-luksroot" = {
          device = "/dev/disk/by-partlabel/${lukspart}";
          preLVM = true;
          allowDiscards = true;

          keyFileSize = 4096;
          keyFile = "/dev/disk/by-id/mmc-EB1QT_0xa5f25355";
        };
      };
    };
  };
}

