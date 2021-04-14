{ pkgs, lib, inputs, modulesPath, ... }:
let
  hostname = "slynux";
  eth = "eth0";
in
{
  imports = [
    ../../mixins/common.nix
    ../../mixins/sshd.nix
    ../../mixins/tailscale.nix
    #../../mixins/xmrig.nix

    ../../profiles/interactive.nix
    ../../profiles/desktop-sway-unstable.nix
  ];

  config = {
    system.stateVersion = "20.03"; # Did you read the comment?
    services.timesyncd.enable = true;

    documentation.nixos.enable = false;

    ###########

    fileSystems = {
      "/boot" = {
        device = "/dev/disk/by-partlabel/slynuxreborn_boot";
        fsType = "vfat";
      };

      "/" = {
        device = "slynuxreborn/root";
        fsType = "zfs";
      };
      "/home" = {
        device = "slynuxreborn/home";
        fsType = "zfs";
      };
      "/nix" = {
        device = "slynuxreborn/nix";
        fsType = "zfs";
      };
    };

    swapDevices = [];

    console.earlySetup = true; # hidpi + luks-open  # TODO : STILL NEEDED?
    console.font = "ter-v32n";
    console.packages = [ pkgs.terminus_font ];

    boot = {
      # tmpOnTmpfs = true;  # re-enable when RAM RMA is complete and we're back to 64GB
      #zfs.requestEncryptionCredentials = true;
      kernelPackages = pkgs.linuxPackages_latest;
      initrd.availableKernelModules = [
        "xhci_pci"
        "nvme"
        "usb_storage"
        "sd_mod"
        "rtsx_pci_sdmmc"
        "intel_agp"
        "i915"
        "hv_vmbus" "hv_storvsc" "hyperv_keyboard" "hid_hyperv" # should've come frm hyperv-guest.nix
      ];
      kernelModules = [
        "xhci_pci"
        "nvme"
        "usb_storage"
        "sd_mod"
        "rtsx_pci_sdmmc"
        "intel_agp"
        "i915"
        "hv_vmbus" "hv_storvsc" "hyperv_keyboard" "hid_hyperv" # should've come frm hyperv-guest.nix
      ];
      kernelParams = [
        # HIGHLY IRRESPONSIBLE
        # not entirely sure these are working
        "noibrs"
        "noibpb"
        "nopti"
        "nospectre_v2"
        "nospectre_v1"
        "l1tf=off"
        "nospec_store_bypass_disable"
        "no_stf_barrier"
        "mds=off"
        "mitigations=off"

        #"i915.modeset=1"     # nixos-hw = missing
        #"i915.enable_guc=3"  # nixos-hw = missing
        #"i915.enable_gvt=0"  # nixos-hw = missing
        #"i915.enable_fbc=1"  # nixos-hw = 2
        #"i915.enable_psr=1"  # nixos-hw = missing?
        #"i915.fastboot=1"    # nixos-hw = missing?
      ];
      supportedFilesystems = [ "zfs" ];
      initrd.supportedFilesystems = [ "zfs" ];
      initrd.luks.devices = {
        root = {
          name = "root";
          device = "/dev/disk/by-partlabel/slynuxreborn_luks";
          preLVM = true;
          allowDiscards = true;

          # disabling this for now
          # so that it doesn't work in Win10
          # see if its the cause of corruption

          #keyFile = "/dev/sdb";
          #keyFileSize = 4096;
          fallbackToPassword = true;
        };
      };
      loader = {
        timeout = 1;
        systemd-boot.enable = true;
        systemd-boot.memtest86.enable = true;
        systemd-boot.configurationLimit = 2;
        efi.canTouchEfiVariables = true;
      };
    };

    # boot.inird.preLVMCommands = ''
    #   function colemickens_lk() {
    #     set -x

    #     kf="/dev/disk/by-partlabel/zfskey"
    #     if [[ -L "''${kf}" ]]; then
    #       mount "${kf}" /tmp/kf
    #       zfs load-key -L /tmp/kf/key -a
    #       umount /tmp/kf
    #     fi

    #     set +x
    #   }

    #   colemickens_lk
    # ''


    networking.hostId = "deadbeef";
    networking.hostName = "slynux";

    networking.usePredictableInterfaceNames = false;
    networking.wireless.enable = false;
    networking.interfaces."${eth}".ipv4.addresses = [
      {
        address = "192.168.1.11";
        prefixLength = 16;
      }
    ];
    networking.defaultGateway = "192.168.1.1";
    networking.nameservers = [ "192.168.1.1" ];
    networking.useDHCP = false;
    networking.firewall.enable = true;

    services.resolved.enable = false;

    nix.maxJobs = 4;
    nixpkgs.config.allowUnfree = true;
    hardware = {
      bluetooth.enable = true;
      pulseaudio.package = pkgs.pulseaudioFull;
      enableRedistributableFirmware = true;
      cpu.intel.updateMicrocode = true;
    };
    services.fwupd.enable = true;
  };
}
