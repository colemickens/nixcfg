{ pkgs, lib, inputs, config, ... }:
let
  hostname = "fajita";
in
{
  imports = [
    ../../profiles/user.nix
    #../../profiles/interactive.nix
    #../../profiles/desktop-sway-unstable.nix
    
    #../../modules/loginctl-linger.nix
    ../../mixins/common.nix
    ../../mixins/sshd.nix
    ../../mixins/networkmanager-minimal.nix
    #../../mixins/tailscale.nix

    (import "${inputs.mobile-nixos}/lib/configuration.nix" {
      device = "oneplus-fajita";
    })
  ];

  config = {
    system.stateVersion = "21.05";

    documentation.enable = false;
    documentation.doc.enable = false;
    documentation.info.enable = false;
    documentation.nixos.enable = false;
    programs.command-not-found.enable = false;
    environment.noXlibs = true;
    security.polkit.enable = false;
    services.udisks2.enable = false;
    boot.enableContainers = false;

    mobile.boot.stage-1.kernel.provenance = "mainline";
    services.udev.packages = [ pkgs.libinput.out ]; # TODO: generic mobile goodness? where is this even from?

    nixpkgs.config.allowUnfree = true;

    boot.growPartition = lib.mkDefault true;
    powerManagement.enable = true;

    systemd.services.systemd-udev-settle.enable = false; ## ????
    # there's no gadgetfs afaict so don't bother:
    mobile.boot.stage-1.shell.enable = false;
    mobile.boot.stage-1.ssh.enable = false;

    mobile.boot.stage-1.bootConfig.log.level = "DEBUG";
    mobile.boot.stage-1.crashToBootloader = true;
    #mobile.boot.stage-1.fbterm.enable = false;         #??????????
    mobile.boot.stage-1.networking.enable = true;       #??????????

    networking.hostName = hostname;
    networking.firewall.enable = false;
    networking.wireless.enable = true;
    networking.networkmanager.enable = true;
    networking.networkmanager.unmanaged = [ "rndis0" "usb0" ];
    services.blueman.enable = false;
    hardware.bluetooth.enable = lib.mkForce false;
  };
}