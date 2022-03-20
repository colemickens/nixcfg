{ pkgs, lib, config, inputs, ... }:
let
  hostname = "pinebook";

  pinebook-fix-sound = (pkgs.writeShellScriptBin "pinebook-fix-sound" ''
    export NIX_PATH="nixpkgs=${toString inputs.nixpkgs}"
    export PATH="${lib.makeBinPath [ pkgs.nix ]}:''$PATH}"
    ${toString inputs.wip-pinebook-pro}/sound/reset-sound.rb
  '');

  # pbpPkgs = (import "${inputs.nixos-unstable}/default.nix" {
  #   system = pkgs.system;
  #   overlays = [ "${inputs.wip-pinebook-pro}/overlay.nix" ];
  # });
  #pinebookpro-keyboard-updater = pbpPkgs.pinebookpro-keyboard-updater;
  #pinebookpro-keyboard-updater = pkgs.hello;
  pinebookpro-keyboard-updater = pkgs.callPackage "${inputs.wip-pinebook-pro}/keyboard-updater" { };
in
{
  imports = [
    ../../mixins/common.nix

    ../../mixins/chromecast.nix
    ../../mixins/sshd.nix
    ../../mixins/syncthing.nix
    ../../mixins/tailscale.nix

    (import ../../profiles/sway { useUnstableOverlay = true; })

    ../../modules/loginctl-linger.nix
    "${inputs.wip-pinebook-pro}/pinebook_pro.nix"
  ];

  config = {
    users.users.cole.linger = true;

    system.stateVersion = "21.05";

    hardware.usbWwan.enable = true;

    nix.nixPath = [ ];
    nix.gc.automatic = true;
    nix.maxJobs = 2;

    documentation.enable = false;
    documentation.doc.enable = false;
    documentation.info.enable = false;
    documentation.nixos.enable = false;

    environment.systemPackages = with pkgs; [
      # TODO: run on boot (?)
      pinebook-fix-sound
      pinebookpro-keyboard-updater
    ];

    systemd.services.pinebook-fix-sound = {
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pinebook-fix-sound}/bin/pinebook-fix-sound";
      };
      wantedBy = [ "multi-user.target" ];
    };

    # ignore unfortunately placed power key
    # TODO: 3s-press or fn-power for shutdown
    services.logind.extraConfig = ''
      HandlePowerKey=ignore
    '';

    fileSystems = {
      "/" = {
        device = "/dev/disk/by-partlabel/nixos";
        #device = "/dev/disk/by-id/mmc-DA4064_0xe0291213-part2";
        fsType = "ext4";
      };
      "/boot" = {
        device = "/dev/disk/by-partlabel/boot";
        #device = "/dev/disk/by-id/mmc-DA4064_0xe0291213-part1";
        fsType = "vfat";
      };
      # firmware can't be mounted, tow-boot has a special setup for pbp's rockchip whatever
    };
    swapDevices = [ ];

    console.earlySetup = true; # luks

    boot = {
      # we use Tow-Boot now:
      loader.grub.enable = false;
      loader.generic-extlinux-compatible.enable = true;
      loader.generic-extlinux-compatible.configurationLimit = 3;

      tmpOnTmpfs = false;
      cleanTmpDir = true;

      kernelParams = [
        # "cma=32M" # samueldr says so
        "mitigations=off"
        "console=ttyS2,1500000n8"
        "console=tty0"
      ];

      initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
      initrd.kernelModules = [ "nvme" ];
    };

    networking = {
      hostId = "ef66d544";
      hostName = hostname;
      firewall.enable = true;
      firewall.allowedTCPPorts = [ 5900 22 ];
      networkmanager.enable = true;
    };
    services.timesyncd.enable = true;
    time.timeZone = "America/Los_Angeles";

    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "pinebookpro-ap6256-firmware"
    ];

    hardware = {
      bluetooth.enable = true;
      pulseaudio.package = pkgs.pulseaudioFull;
      enableRedistributableFirmware = true;
    };
    services.fwupd.enable = true;
  };
}
