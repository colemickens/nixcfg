{ config, pkgs, ... }:

{
  config = {
    hardware.opengl = {
      enable = true;
      setLdLibraryPath = true;
      package = pkgs.mesa_drivers;
    };
    hardware.deviceTree = {
      base = pkgs.device-tree_rpi;
      overlays = [ "${pkgs.device-tree_rpi.overlays}/vc4-fkms-v3d.dtbo" ];
    };

    sound.enable = true;
    hardware.pulseaudio.enable = pkgs.lib.mkForce true;
    #hardware.pulseaudio.package = pkgs.pulseaudioFull;
    services.dbus.enable = true;
    services.dbus.socketActivated = true;

    nixpkgs.config.pulseaudio = true;

    environment.systemPackages = with pkgs; [
      firefox
      chromium
      pulsemixer
      plex-mpv-shim
    ];

    boot.loader.raspberryPi.firmwareConfig = ''
      gpu_mem=192
      disable_overscan=1
      hdmi_drive=2
      dtparam=audio=on
    '';
  };
}
