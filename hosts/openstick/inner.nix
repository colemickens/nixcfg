{ pkgs, lib, inputs, config, ... }:

let
  hn = "openstick";
  static_wifi_addr = "192.168.2.90";
  static_wifi_prefix = 16;
in
{
  imports = [
    ./unfree.nix
    ../../profiles/core.nix

    ../../mixins/nix.nix
    ../../mixins/sshd.nix
    ../../mixins/tailscale.nix
    ../../mixins/iwd-networks.nix
    ../../mixins/iwd-auto-ap.nix

    ../../secrets

    (import "${inputs.mobile-nixos-openstick}/lib/configuration.nix" {
      device = "openstick";
    })
  ];

  config = {
    nixpkgs.hostPlatform.system = "aarch64-linux";

    boot.initrd.systemd.enable = lib.mkForce false;

    nixcfg.common = {
      defaultKernel = false;
    };

    system.stateVersion = "22.05";
    environment.systemPackages = with pkgs; [ usbutils lshw libqmi ];

    networking = {
      hostName = hn;
      networkmanager = {
        enable = true;
        wifi.backend = "iwd";
      };
      interfaces."wlan0" = {
        ipv4.addresses = [{
          address = static_wifi_addr;
          prefixLength = static_wifi_prefix;
        }];
      };
      defaultGateway = "192.168.1.1";
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
      settings = {
        PasswordAuthentication = lib.mkForce true;
      };
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
