{ pkgs, inputs, ... }:
let
  hostname = "pinebook";
in
{
  imports = [
    ../../mixins/common.nix

    ../../mixins/chromecast.nix
    ../../mixins/sshd.nix
    ../../mixins/tailscale.nix
    ../../mixins/v4l2loopback.nix
    ../../mixins/wlsunset.nix

    ../../profiles/interactive.nix
    ../../profiles/desktop-sway.nix

    inputs.wip-pinebook-pro.nixosModule
    # TODO: ^ module isn't arch specific
    # TODO: ^ boot options should be exposed too
  ];

  config = {
    environment.systemPackages = with pkgs; [
      drm-howto
      virt-viewer
      (pkgs.writeScriptBin "pinebook-fix-sound" ''
        export NIX_PATH="nixpkgs=${toString inputs.nixpkgs}"
        ${toString inputs.wip-pinebook-pro}/sound/reset-sound.rb
      '')
    ];
    boot.loader.grub.enable = false;
    boot.loader.generic-extlinux-compatible.enable = true;

    boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
    boot.initrd.kernelModules = [ "nvme" ];

    services.logind.extraConfig = ''
      # TODO: figure out how to reverse `del+power`, `fn+del` for power wouldn't be the worst
      HandlePowerKey=ignore
    '';

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
      "/" =     { fsType = "ext4"; device = "/dev/disk/by-partlabel/nixos"; };
      "/boot" = { fsType = "vfat"; device = "/dev/disk/by-partlabel/boot"; };
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
