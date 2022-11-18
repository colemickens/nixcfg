{ pkgs, lib, inputs, config, ... }:

{
  imports = [
    # ../../profiles/phone.nix

    ./unfree.nix
    # ../../mixins/common.nix
    ../../mixins/tailscale.nix
    # ../../mixins/ssh.nix
    ../../mixins/sshd.nix
    # ../../mixins/wpa-slim.nix
    # ../../mixins/nmiot.nix
    ../../mixins/iwd-networks.nix
    ../../mixins/nix.nix
    ../../profiles/user.nix
    # ../../profiles/info
    # ../../profiles/core.nix
    # ../../profiles/interactive.nix

    ../../profiles/phosh

    (import "${inputs.mobile-nixos-reset-scripts}/lib/configuration.nix" {
      device = "oneplus-enchilada";
    })
  ];

  config = {
    documentation = {
      doc.enable = false;
      dev.enable = false;
      info.enable = false;
      nixos.enable = false;
    };

    networking.networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };

    system.stateVersion = "22.05";
    system.build.android-serial = "b205392d";
    security.sudo.wheelNeedsPassword = false;

    services.timesyncd.enable = true;

    networking.hostName = "enchilada";
    hardware.firmware = lib.mkBefore [ config.mobile.device.firmware ];

    mobile.system.android.boot_partition_destination = "boot_a";
    mobile.system.android.system_partition_destination = "userdata";
    #mobile.system.android.system_partition_destination = "system_a";

    networking.interfaces."wlan0".useDHCP = true;
    networking.interfaces."usb0".useDHCP = true;

    # auto-start modem manager
    systemd.services."ModemManager".wantedBy = [ "multi-user.target" ];

    ## !!!!!!!!!!!!!!!!!!!!!!!!
    # usb0 appears even with this disabled:
    # (not sure if true after kernel combo ^)
    mobile.boot.stage-1.networking.enable = true;
    ## !!!!!!!!!!!!!!!!!!!!!!!!
  };
}
