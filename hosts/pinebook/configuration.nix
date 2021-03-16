{ pkgs, lib, config, inputs, ... }:
let
  hostname = "pinebook";
in
{
  imports = [
    ../../mixins/common.nix

    ../../mixins/chromecast.nix
    ../../mixins/sshd.nix
    ../../mixins/tailscale.nix

    ../../modules/rtl88x2bu.nix

    ../../profiles/desktop-sway-unstable.nix

    inputs.wip-pinebook-pro.nixosModule
  ];

  config = {
    system.stateVersion = "21.03";

    nix.nixPath = [];
    nix.gc.automatic = true;
    nix.maxJobs = 2;

    documentation.enable = false;
    documentation.doc.enable = false;
    documentation.info.enable = false;
    documentation.nixos.enable = false;

    environment.systemPackages = with pkgs; [
      drm-howto
      virt-viewer
      (pkgs.writeScriptBin "pinebook-fix-sound" ''
        export NIX_PATH="nixpkgs=${toString inputs.nixpkgs}"
        ${toString inputs.wip-pinebook-pro}/sound/reset-sound.rb
      '')
    ];

    # ignore unfortunately placed power key
    # TODO: 3s-press or fn-power for shutdown
    services.logind.extraConfig = ''
      HandlePowerKey=ignore
    '';

    fileSystems = {
      "/" =     {
        device = "/dev/disk/by-partlabel/nixos";
        fsType = "ext4";
      };
      "/boot" = {
        device = "/dev/disk/by-partlabel/boot";
        fsType = "vfat";
      };
    };
    swapDevices = [];

    console.earlySetup = true; # hidpi + luks-open  # TODO : STILL NEEDED?
    console.font = "ter-v32n";
    console.packages = [ pkgs.terminus_font ];

    boot = {
      tmpOnTmpfs = false;
      cleanTmpDir = true;

      loader.grub.enable = false;
      loader.generic-extlinux-compatible.enable = true;

      initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
      initrd.kernelModules = [ "nvme" ];
      consoleLogLevel = pkgs.lib.mkDefault 7;

      #block this, display still doesn't work in 5.11
      kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
      kernelPatches = [

        { name = "pinebook-disable-dp";
          # https://patchwork.kernel.org/project/linux-rockchip/patch/20200924063042.41545-1-jhp@endlessos.org/
          patch = ./pbp-disable-dp.patch; }

        { name = "pinebook-force-enable-battery";
          patch = null;
          extraConfig = ''
            BATTERY_CW2015=y
          ''; }

      ];

      kernelParams = [
        "cma=32M"
        "mitigations=off"
        "console=ttyS2,1500000n8" "console=tty0"
      ];
    };

    networking = {
      hostId = "ef66d544";
      hostName = hostname;
      firewall.enable = true;
      firewall.allowedTCPPorts = [ 5900 22 ];
      networkmanager.enable = false;
      wireless.iwd.enable = true;
      useNetworkd = true;
      useDHCP = false;
      interfaces."wlan0".useDHCP = true;
      interfaces."eth0".useDHCP = true;
      search = [ "ts.r10e.tech" ];
    };
    services.timesyncd.enable = true;
    services.resolved.enable = true;
    services.resolved.domains = [ "ts.r10e.tech" ];
    systemd.network.enable = true;

    nixpkgs.config.allowUnfree = true;
    hardware = {
      bluetooth.enable = true;
      pulseaudio.package = pkgs.pulseaudioFull;
      enableRedistributableFirmware = true;
    };
  };
}
