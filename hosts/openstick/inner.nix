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
    # ../../mixins/iwd-auto-ap.nix # not sure it works, worried it causes problems, but might be something else

    # (import "${inputs.mobile-nixos-openstick}/lib/configuration.nix" {
    #   device = "openstick";
    # })
    inputs.mobile-nixos-openstick.nixosModules.devices.openstick
  ];

  config = {
    nixpkgs.hostPlatform.system = "aarch64-linux";

    boot.initrd.systemd.enable = lib.mkForce false;

    system.build.initialRamdisk = lib.mkForce (pkgs.writeText "test" "null").outPath;

    nixcfg.common = {
      defaultKernel = false;
    };

    nix = {
      gc = {
        automatic = true;
        persistent = true;
      };
    };

    system.stateVersion = "22.05";
    environment.systemPackages = with pkgs; [
      dua
      # usbutils
      # lshw
      # libqmi
    ];

    networking = {
      hostName = hn;
      networkmanager = {
        enable = true;
        wifi.backend = "iwd";
      };
      interfaces."wlan0" = {
        # doesn't work, not sure why
        # maybe NM? who knows about nixos scripted network
        # i would use networkd but idk how that plays with NM+MM...
        ipv4.addresses = [{
          address = static_wifi_addr;
          prefixLength = static_wifi_prefix;
        }];
      };
      defaultGateway = "192.168.1.1";
    };

    # boot.loader.generic-extlinux-compatible.enable = true;
    boot.loader.generic-extlinux-compatible.configurationLimit = 2;
    boot.loader.systemd-boot.enable = lib.mkForce false;
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
    # hardware.bluetooth.enable = true;
    hardware.bluetooth.enable = lib.mkForce false;

    # auto-start modem manager
    # networking.networkmanager.plugins = lib.mkForce []; # TODO: remove, I don't think this does anything
    # systemd.services."ModemManager".wantedBy = [ "multi-user.target" ];

    documentation.enable = false;
    documentation.doc.enable = false;
    documentation.info.enable = false;
    documentation.nixos.enable = false;
  };
}
