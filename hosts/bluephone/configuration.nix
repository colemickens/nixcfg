{ pkgs, lib, inputs, ... }:
let
  hostname = "bluephone";
  extras = with pkgs; [
    drm-howto
    dtc
  ];
in
{
  imports = [
    ../../profiles/user.nix
    ../../profiles/interactive.nix
    #../../profiles/desktop-sway-unstable.nix
    
    ../../modules/loginctl-linger.nix
    ../../mixins/common.nix
    ../../mixins/sshd.nix
    ../../mixins/tailscale.nix

    (import "${inputs.mobile-nixos}/lib/configuration.nix" {
      device = "google-blueline";
    })
  ];

  config = {
    mobile.boot.stage-1.kernel.provenance = "mainline";

    services.udev.packages = [ pkgs.libinput.out ];
    documentation.enable = false;
    programs.command-not-found.enable = false;

    nixpkgs.config.allowUnfree = true;

    boot.growPartition = lib.mkDefault true;
    powerManagement.enable = true;

    ### BEGIN HACKY COPY
    systemd.services.systemd-udev-settle.enable = false;
    # networking.firewall.enable = false; # ???

    ## <debug> pivot->stage-2, ext4 issues, etc
    mobile.boot.stage-1.shell.enable = false;
    mobile.boot.stage-1.ssh.enable = false;
    ## </debug>

    mobile.boot.stage-1.bootConfig.log.level = "DEBUG";
    mobile.boot.stage-1.crashToBootloader = true;
    mobile.boot.stage-1.fbterm.enable = false;
    mobile.boot.stage-1.networking.enable = true;
      /*
      sudo ip link set usb0 up
      sudo ip addr add 172.16.42.2/24 dev usb0
      sudo ip addr add brd 172.16.42.255 dev usb0
      sudo ip route add 172.16.42.0/24 dev usb0
      */
    #mobile.boot.stage-1.ssh.enable = false; # breaks stage-2 ssh
    mobile.boot.stage-1.extraUtils = extras;

    networking.firewall.enable = false;

    networking.hostName = hostname;

    networking.networkmanager.enable = true;
    networking.networkmanager.unmanaged = [ "rndis0" "usb0" ];
    services.blueman.enable = true;
    hardware.bluetooth.enable = true;

    ##
    ### CAGE
    # hardware = {
    #   bluetooth.enable = true;
    #   pulseaudio.package = pkgs.pulseaudioFull;
    #   enableRedistributableFirmware = true;
    # };
    # services.fwupd.enable = true;

    # users.users.kiosk = {
    #   isNormalUser = true;
    #   useDefaultShell = true;
    # };
    # systemd.services."cage@" = {
    #   serviceConfig.Restart = "always";
    #   environment = {
    #     WLR_LIBINPUT_NO_DEVICES = "1";
    #     NO_AT_BRIDGE = "1";
    #   };
    # };
    # systemd.enableEmergencyMode = false;
    # systemd.services."serial-getty@ttyS0".enable = false;
    # systemd.services."serial-getty@hvc0".enable = false;
    # systemd.services."getty@tty1".enable = false;
    # systemd.services."autovt@".enable = false;
    # services.cage = {
    #   enable = true;
    #   user = "kiosk";
    # };
  };
}