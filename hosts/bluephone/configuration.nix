{ pkgs, lib, inputs, ... }:
let
  hostname = "bluephone";
in
{
  imports = [
    (import "${inputs.mobile-nixos}/lib/configuration.nix" {
      device = "google-blueline";
    })

    ../../mixins/sshd.nix

    ../../mixins/common.nix #?
    ../../profiles/sway.nix
  ];

  config = {
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
      mobile.boot.stage-1.extraUtils = with pkgs; [ drm-howto ];
      
      ### BEGIN HACKY COPY
      boot.growPartition = lib.mkDefault true;
      powerManagement.enable = true;
      hardware.pulseaudio.enable = true;

      environment.systemPackages = with pkgs; [
        drm-howto
        (writeShellScriptBin "firefox" ''
          export MOZ_USE_XINPUT2=1
          exec ${pkgs.firefox}/bin/firefox "$@"
        '')
        sgtpuzzles
      ];

      networking.firewall.enable = false;

      networking.networkmanager.enable = true;
      networking.networkmanager.unmanaged = [ "rndis0" "usb0" ];
      services.blueman.enable = true;
      hardware.bluetooth.enable = true;
  };
}