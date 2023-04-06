{ pkgs, lib, modulesPath, inputs, config, ... }:

let
  _networks = {
    "10-eth0".addresses = [{
      addressConfig = {
        Address = "192.168.63.253/16"; # uboot/nixos onboard eth
      };
    }];
  };
in
{
  imports = [
    ../../profiles/user-cole.nix

    # ../../mixins/common.nix
    ../../mixins/sshd.nix
    ../../mixins/tailscale.nix

    ../../mixins/netboot-client.nix

    # ../../modules/preinstalled-disk.nix # prototyping for "ezsbc"

    # the visionfive module pulls in the nixos-riscv64 overlay automatically:
    # "${inputs.riscv64}/nixos/visionfive.nix"
    inputs.visionfive-nix.nixosModules.riscv-cross-quirks
    inputs.visionfive-nix.nixosModules.visionfive
    # inputs.visionfive-nix.nixosModules.sdcard
    # inputs.visionfive-nix.nixosModules.sdcard # TODO: replace with our own custom installed-disk.nix module

    inputs.tow-boot-visionfive.nixosModules.default
  ];

  config = {
    system.build = rec {
      sbc_serial = "C0A83FFD";
      sbc_mac = "6c-cf-39-00-01-33";
      sbc_ubootid = "01-${sbc_mac}";
      mbr_disk_id = "99995551";
    };
    system.build.flasher = config.system.build.towbootBuild.config.Tow-Boot.outputs.extra.flasher inputs.nixpkgs.legacyPackages.x86_64-linux;
    system.build.vffw = config.system.build.towbootBuild.config.Tow-Boot.outputs.extra.vffw;

    tow-boot = {
      enable = true;
      # autoUpdate = true;
      device = "starFive-visionFive";
      sys = "x86_64-linux";
      # sys = "riscv64-linux";
      config = ({
        diskImage.mbr.diskID = config.system.build.mbr_disk_id;
        # uBootVersion = "2022.07";
        # useDefaultPatches = false;
        # withLogo = false;
        # how to override source
        # or give more patches?
      });
    };

    networking.hostName = "risky";

    # nixcfg.common.useZfs = false;
    # nixcfg.common.defaultNetworking = false;

    boot.initrd.systemd.network.networks = _networks;
    systemd.network.networks = _networks;

    nixpkgs.crossSystem.system = "riscv64-linux";
    nixpkgs.overlays = [
      # TODO: port out whatever is needed from that repo
      inputs.visionfive-nix.overlay

      # this is stupid, make my own netboot module:
      (final: prev: {
        grub2_efi = prev.writeShellScriptBin "foo" "bar";
        syslinux = prev.writeShellScriptBin "foo" "bar";
      })
    ];
    system.stateVersion = "22.05";

    system.disableInstallerTools = true;

    documentation.enable = false;
    documentation.doc.enable = false;
    documentation.info.enable = false;
    documentation.man.enable = false;
    documentation.nixos.enable = false;

    security.polkit.enable = false;
    services.udisks2.enable = lib.mkForce false;
    hardware.bluetooth.enable = false;

    nix.nixPath = [ ];
    nix.gc.automatic = true;


    services.fwupd.enable = lib.mkForce false;

    environment.systemPackages = with pkgs; [
      binutils
      usbutils
    ];

    # fileSystems = {
    #   # "/boot/firmware" = {
    #   #   fsType = "vfat";
    #   #   device = "/dev/disk/by-label/FIRMWARE";
    #   # };
    #   "/" = {
    #     device = "/dev/disk/by-label/NIXOS_SD";
    #     fsType = "ext4";
    #     # fsType = "zfs"; device = "tank2/root";
    #   };
    # };

    boot = {
      loader = {
        grub.enable = lib.mkForce false;
        generic-extlinux-compatible.enable = true;
        generic-extlinux-compatible.configurationLimit = 3;
      };
      tmpOnTmpfs = false;
      cleanTmpDir = true;
    };
    boot.kernelParams = [
      # https://github.com/starfive-tech/linux/issues/14
      "stmmac.chain_mode=1"
    ];
    boot.initrd.kernelModules = [
      "brcmfmac"
      "dwmac_generic"
      "dw_axi_dmac_platform"
      "dw_mmc-pltfm"
      "spi-dw-mmio"
      "motorcomm"
      "stmmac"
      "stmmac-platform"
      "af_packet"
    ];
    boot.kernelModules = config.boot.initrd.kernelModules;

    # TODO: move some more of this to common?
    networking = {
      firewall.enable = true;
      firewall.allowedTCPPorts = [ 22 ];
      networkmanager.enable = false;
    };
    services.timesyncd.enable = true;
    time.timeZone = "America/Los_Angeles";

  };
}
