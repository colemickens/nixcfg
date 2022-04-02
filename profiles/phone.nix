{ pkgs, lib, inputs, config, ... }:

{
  imports = [
    ../profiles/sway
    ../mixins/wpasupplicant.nix
  ];

  config = {
    system.build.mobile-flash-boot = let
      d = config.mobile.system.android.device_name;
      bootzip = config.mobile.outputs.android.android-flashable-bootimg;
    in pkgs.writeShellScript "flash-${d}.sh" ''
      set -x
      set -euo pipefail
      
      action="''${1:-}"; shift
      export ANDROID_SERIAL="${config.system.build.android-serial}"
      
      unar "${bootzip}" 'boot.img' -o - >/tmp/boot.img
      timeout 60 fastboot flash boot /tmp/boot.img
        
      if [[ "''${action}" == "reboot" ]]; then fastboot reboot; fi
    '';
    # the phones are using custom kernels
    # TODO: TODO:
    # - mobile-nixos needs to warn/error aggressively
    #   if the user has overriden the boot.kernelPackages:
    nixcfg.common.defaultKernel = false;

    boot.kernelParams = [ "nofb" ];
    
    environment.interactiveShellInit = ''
      alias rbb="sudo reboot bootloader"
    '';

    home-manager.users.cole = { pkgs, ... }: {
      programs.waybar.enable = lib.mkForce false;
    };
    
    services.udev.packages = [ pkgs.libinput.out ]; # TODO: generic mobile goodness? where is this even from?
    
    services.getty.autologinUser = "cole";
    environment.sessionVariables = { AUTOLOGIN_CMD = (pkgs.writeShellScript "sway-start" ''
      env
    
      sway
    '').outPath; };

    systemd.services.systemd-udev-settle.enable = false; ## ????
    # mobile.boot.stage-1.ssh.enable = false;
    mobile.boot.stage-1.bootConfig.log.level = "DEBUG";
    mobile.boot.stage-1.crashToBootloader = true;
    #mobile.boot.stage-1.fbterm.enable = false;         #??????????

    services.blueman.enable = false;
    hardware.bluetooth.enable = lib.mkForce false;
  };
}