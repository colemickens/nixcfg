{ pkgs, inputs, ... }:
let
  hostname = "pinebook";
in
{
  imports = [
    ../../mixins/common.nix

    ../../mixins/chromecast.nix
    ../../mixins/sshd.nix
    ../../mixins/v4l2loopback.nix

    ../../profiles/sway.nix

    inputs.wip-pinebook-pro.nixosModule
    # TODO: ^ module isn't arch specific
    # TODO: ^ boot options should be exposed too
  ];

  config = {      
    boot.loader.grub.enable = false;
    boot.loader.generic-extlinux-compatible.enable = true;
  
    boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
    boot.initrd.kernelModules = [ "nvme" ];

    boot.consoleLogLevel = pkgs.lib.mkDefault 7;

    boot.kernelParams = [
      "cma=32M"
      #"console=ttyS0,115200n8" "console=ttyAMA0,115200n8" "console=tty0"

      "console=ttyS2,1500000n8"
      "earlycon=uart8250,mmio32,0xff1a0000" "earlyprintk"

      # The last console parameter will be where the boot process will print
      # its messages. Comment or move abot ttyS2 for better serial debugging.
      "console=tty0"
    ];
    
    nix = {
      nixPath = [];
    };

    system.stateVersion = "20.03"; # Did you read the comment?
    services.timesyncd.enable = true;
    
    documentation.enable = false;
    documentation.nixos.enable = false;

    fileSystems = {
      "/" =     { fsType = "ext4"; device = "/dev/nvme0n1p2"; };
      "/boot" = { fsType = "vfat"; device = "/dev/disk/by-partlabel/nvme-boot"; };
    };
    swapDevices = [];

    console.earlySetup = true; # hidpi + luks-open  # TODO : STILL NEEDED?
    console.font = "ter-v32n";
    console.packages = [ pkgs.terminus_font ];

    networking = {
      hostId = "ef66d544";
      hostName = hostname;
      firewall = {
        enable = true;
        allowedTCPPorts = [ 5900 22 ];
      };
      networkmanager.enable = true;
      networkmanager.wifi.backend = "iwd";
      wireguard.enable = true;
    };
    services.resolved.enable = true;

    nix.maxJobs = 2;
    nixpkgs.config.allowUnfree = true;
    hardware = {
      bluetooth.enable = true;
      pulseaudio.package = pkgs.pulseaudioFull;
      enableRedistributableFirmware = true;
    };
    #services.fwupd.enable = true; #tpm2/trifecta(hk)/etc on aarch64 bad
  };
}
