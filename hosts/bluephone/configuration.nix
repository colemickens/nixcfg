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
    (import "${inputs.mobile-nixos}/lib/configuration.nix" {
      #inherit pkgs;
      device = "google-blueline";
    })

    ../../mixins/docker.nix
    ../../mixins/sshd.nix

    ../../mixins/common.nix #?
  ];

  config = {
    mobile.boot.stage-1.kernel.provenance = "mainline";

    services.udev.packages = [ pkgs.libinput.out ];

  users.users.kiosk = {
    isNormalUser = true;
    useDefaultShell = true;
  };

  systemd.services."cage@" = {
    serviceConfig.Restart = "always";
    environment = {
      WLR_LIBINPUT_NO_DEVICES = "1";
      NO_AT_BRIDGE = "1";
    };
  };

  systemd.enableEmergencyMode = false;
  systemd.services."serial-getty@ttyS0".enable = false;
  systemd.services."serial-getty@hvc0".enable = false;
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@".enable = false;

  documentation.enable = false;
  programs.command-not-found.enable = false;

  services.cage = {
    enable = true;
    user = "kiosk";
  };









      nixpkgs.config.allowUnfree = true;
      nixpkgs.overlays = [
        inputs.self.overlay
        inputs.nixpkgs-wayland.overlay
      ];

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
      
      ### BEGIN HACKY COPY
      systemd.services.systemd-udev-settle.enable = false;

      boot.growPartition = lib.mkDefault true;
      powerManagement.enable = true;
      hardware.pulseaudio.enable = true;

      environment.systemPackages = with pkgs; [
        (writeShellScriptBin "firefox" ''
          export MOZ_USE_XINPUT2=1
          exec ${pkgs.firefox}/bin/firefox "$@"
        '')
        sgtpuzzles
      ] ++ extras;

      networking.firewall.enable = false;

      networking.networkmanager.enable = true;
      networking.networkmanager.unmanaged = [ "rndis0" "usb0" ];
      services.blueman.enable = true;
      hardware.bluetooth.enable = true;
  };
}