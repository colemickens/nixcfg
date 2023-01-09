{ pkgs, lib, inputs, config, ... }:

let
  hostname = "openstick";
in
{
  imports = [
    ./unfree.nix
    ../../profiles/addon-cross.nix

    # ../../mixins/common.nix
    # ../../mixins/helix.nix
    # ../../mixins/ssh.nix
    ../../mixins/nix.nix
    ../../mixins/sshd.nix
    ../../mixins/tailscale.nix
    ../../mixins/iwd-networks.nix
    ../../mixins/iwd-auto-ap.nix
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
    nixpkgs.hostPlatform.system = "aarch64-linux";

    system.stateVersion = "22.05";
    networking.hostName = hostname;
    environment.systemPackages = with pkgs; [ usbutils lshw libqmi ];

    networking.networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };

    boot.loader.generic-extlinux-compatible.configurationLimit = 2;
    security.sudo.wheelNeedsPassword = false;
    systemd.network.wait-online.anyInterface = true;

    users.users."openstick" = {
      isNormalUser = true;
      password = "openstick2022";
    };

    services.openssh = {
      enable = true;
      passwordAuthentication = lib.mkForce true;
    };

    # I think this is needed for firmware to be present in stage-2 when wpa/something
    # fires it up?
    # COMPRESS_FW_LOADER was needed to be enabled in the kernel
    hardware.firmware = lib.mkBefore [ config.mobile.device.firmware ];
    hardware.bluetooth.enable = true;

    # auto-start modem manager
    # networking.networkmanager.plugins = lib.mkForce []; # TODO: remove, I don't think this does anything
    # systemd.services."ModemManager".wantedBy = [ "multi-user.target" ];

    documentation.enable = false;
    documentation.doc.enable = false;
    documentation.info.enable = false;
    documentation.nixos.enable = false;
  };
}
