{ pkgs, lib, inputs, config, ... }:

{
  imports = [
    #../profiles/sway
    ../profiles/core.nix

    ../modules/loginctl-linger.nix
    ../mixins/sshd.nix
    ../mixins/networkmanager-minimal.nix
    ../mixins/tailscale.nix
  ];

  config = {
    environment.interactiveShellInit = ''
      alias rbb="sudo reboot bootloader"
    '';

    services.udev.packages = [ pkgs.libinput.out ]; # TODO: generic mobile goodness? where is this even from?

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