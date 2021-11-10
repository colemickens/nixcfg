{ pkgs, lib, inputs, config, ... }:

{
  imports = [
    ../profiles/user.nix
    ../profiles/interactive.nix
    #../../profiles/desktop-sway-unstable.nix

    ../modules/loginctl-linger.nix
    ../mixins/common.nix
    ../mixins/sshd.nix
    ../mixins/networkmanager-minimal.nix
    ../mixins/tailscale.nix
    ../modules/tailscale-autoconnect.nix
  ];

  config = {
    environment.interactiveShellInit = ''
      alias rbb="sudo reboot bootloader"
    '';

    documentation.enable = false;
    documentation.doc.enable = false;
    documentation.info.enable = false;
    documentation.nixos.enable = false;
    programs.command-not-found.enable = false;
    #environment.noXlibs = true;
    security.polkit.enable = false;
    services.udisks2.enable = false;

    services.udev.packages = [ pkgs.libinput.out ]; # TODO: generic mobile goodness? where is this even from?

    nixpkgs.config.allowUnfree = true;

    systemd.services.systemd-udev-settle.enable = false; ## ????
    # mobile.boot.stage-1.ssh.enable = false;
    mobile.boot.stage-1.bootConfig.log.level = "DEBUG";
    #mobile.boot.stage-1.crashToBootloader = true;
    #mobile.boot.stage-1.fbterm.enable = false;         #??????????

    networking = {
      firewall.enable = true;
      firewall.allowedTCPPorts = [ 22 ];
      networkmanager.enable = true; # cairo doesn't cross compile
      networkmanager.unmanaged = [ "rndis0" "usb0" ];
    };
    services.blueman.enable = false;
    hardware.bluetooth.enable = lib.mkForce false;
  };
}