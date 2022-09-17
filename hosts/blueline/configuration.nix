{ pkgs, lib, inputs, config, ... }:

{
  imports = [
    ./unfree.nix
    # ../../mixins/common.nix
    ../../mixins/tailscale.nix
    # ../../mixins/ssh.nix
    ../../mixins/sshd.nix
    # ../../mixins/wpa-slim.nix
    ../../mixins/nmiot.nix
    ../../mixins/nix.nix
    ../../profiles/user.nix
    # ../../profiles/core.nix
    # ../../profiles/interactive.nix

    ../../profiles/plamo

    (import "${inputs.mobile-nixos-blueline}/lib/configuration.nix" {
      device = "google-blueline";
    })
  ];

  config = {
    system.stateVersion = "22.05";
    networking.hostName = "blueline";
    # nixpkgs.crossSystem.system = "aarch64-linux";

    security.sudo.wheelNeedsPassword = false;
    system.build.android-serial = "89WX0J2GL";

    documentation = {
      doc.enable = false;
      dev.enable = false;
      info.enable = false;
      nixos.enable = false;
    };
    virtualisation = {
      # waydroid.enable = true;
      # lxc.enable = true;
      # lxc.lxcfs.enable = true;
      # lxd.enable = true;
      # lxd.zfsSupport = false;
    };

    boot.kernelParams = lib.mkAfter [ "loglevel=7" ];
    hardware.firmware = lib.mkBefore [ config.mobile.device.firmware ];

    networking.interfaces."wlan0".useDHCP = true;
    networking.interfaces."usb0".useDHCP = true;

    # auto-start modem manager
    systemd.services."ModemManager".wantedBy = [ "multi-user.target" ];

    # usb0 never appears with this disabled:
    # mobile.boot.stage-1.networking.enable = true;

    # networking.wireless.iwd.enable = true;
  };
}
