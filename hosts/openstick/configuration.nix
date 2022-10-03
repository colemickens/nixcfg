{ pkgs, lib, inputs, config, ... }:

let
  hostname = "openstick";
in
{
  imports = [
    ./unfree.nix
    # ../../mixins/common.nix
    # ../../mixins/helix.nix
    # ../../mixins/ssh.nix
    ../../mixins/nix.nix
    ../../mixins/sshd.nix
    ../../mixins/tailscale.nix
    ../../mixins/nmiot.nix
    # ../../mixins/wpa-slim.nix
    # ../../mixins/zellij.nix
    ../../profiles/user.nix
    # ../../profiles/core.nix
    # ../../profiles/interactive.nix

    ../../secrets

    (import "${inputs.mobile-nixos-openstick}/lib/configuration.nix" {
      device = "openstick";
    })
  ];

  config = {
    system.stateVersion = "22.05";
    networking.hostName = "openstick";
    environment.systemPackages = with pkgs; [
      usbutils
      lshw
      binwalk
      nload
      iperf
      zellij
      bottom
      libqmi
    ];

    security.sudo.wheelNeedsPassword = false;

    # I think this is needed for firmware to be present in stage-2 when wpa/something
    # fires it up?
    # COMPRESS_FW_LOADER was needed to be enabled in the kernel
    hardware.firmware = lib.mkBefore [ config.mobile.device.firmware ];
    hardware.bluetooth.enable = true;

    # auto-start modem manager
    systemd.services."ModemManager".wantedBy = [ "multi-user.target" ];

    documentation.enable = false;
    documentation.doc.enable = false;
    documentation.info.enable = false;
    documentation.nixos.enable = false;
  };
}
