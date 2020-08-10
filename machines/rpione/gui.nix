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
    hardware.pulseaudio.package = pkgs.pulseaudioFull;
    services.dbus.enable = true;
    services.dbus.socketActivated = true;

    nixpkgs.config.pulseaudio = true;

    environment.systemPackages = with pkgs; [
      #firefox
      #chromium
      pulsemixer
      ffmpeg_4
      vlc
    ];


    # according to the issue I opened on kioskix, it might be for tablets
    services.udev.packages = [ pkgs.libinput.out ];

    systemd.services."cage-tty1" = {
      serviceConfig.Restart = "always";
      environment = {
        WLR_LIBINPUT_NO_DEVICES = "1";
        XDG_DATA_DIRS = "/nix/var/nix/profiles/default/share:/run/current-system/sw/share";
        XDG_CONFIG_DIRS = "/nix/var/nix/profiles/default/etc/xdg:/run/current-system/sw/etc/xdg";
        # GDK_PIXBUF_MODULE_FILE = config.environment.variables.GDK_PIXBUF_MODULE_FILE;
        WEBKIT_DISABLE_COMPOSITING_MODE = "1";
      };
    };

    #systemd.enableEmergencyMode = false;
    #systemd.services."serial-getty@ttyS0".enable = false;
    #systemd.services."serial-getty@hvc0".enable = false;
    #systemd.services."getty@tty1".enable = false;
    #systemd.services."autovt@".enable = false;

    services.udisks2.enable = false;
    documentation.enable = false;
    powerManagement.enable = false;
    programs.command-not-found.enable = false;
  
    users.users.kiosk = {
      isNormalUser = true;
      useDefaultShell = true;
    };
    services.cage = {
      enable = true;
      user = "kiosk";
      program = "${pkgs.plex-mpv-shim}/bin/plex-mpv-shim";
    };

    services.avahi = {
      enable = true;
      #nssmdns = true;
      publish = {
        enable = true;
        userServices = true;
        addresses = true;
        hinfo = true;
        workstation = true;
        domain = true;
      };
    };
    environment.etc."avahi/services/ssh.service" = {
      text = ''
        <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
        <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
        <service-group>
          <name replace-wildcards="yes">%h</name>
          <service>
            <type>_ssh._tcp</type>
            <port>22</port>
          </service>
        </service-group>
      '';
    };
    boot.loader.raspberryPi.firmwareConfig = ''
      gpu_mem=192
      disable_overscan=1
      hdmi_drive=2
      dtparam=audio=on
    '';
  };
}
