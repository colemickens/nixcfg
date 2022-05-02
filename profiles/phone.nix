{ pkgs, lib, inputs, config, ... }:

{
  imports = [
    ../profiles/sway
    ../mixins/wpa-slim.nix
    ../mixins/gfx-debug.nix
    ../mixins/hidpi.nix
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

      # unar "${bootzip}" 'dtb.img' -o - >/tmp/dtb.img
      # timeout 60 fastboot flash dtbo /tmp/dtb.img
        
      if [[ "''${action}" == "reboot" ]]; then fastboot reboot; fi
    '';
    # the phones are using custom kernels
    # TODO: TODO:
    # - mobile-nixos needs to warn/error aggressively
    #   if the user has overriden the boot.kernelPackages:
    nixcfg.common.defaultKernel = false;

    # boot.kernelParams = [ "nofb" ];
    
    home-manager.users.cole = { pkgs, ... }: {
      # why?
      # programs.waybar.enable = lib.mkForce false;
    };
    
    environment.systemPackages = with pkgs; [
      # just a hack so that we ensure the kernel gets cached
      # since we don't cached the boot.img for hopefully obvious reasons
      config.mobile.boot.stage-1.kernel.package
    ];
    
    services.udev.packages = [ pkgs.libinput.out ]; # TODO: generic mobile goodness? where is this even from?
    # services.upower.enable = true; # TODO poweralertd happiness
    
    services.getty.autologinUser = "cole";
    environment.sessionVariables.AUTOLOGIN_CMD = ((pkgs.writeShellScript "zellij-attach-c-autologin.sh" ''
      set -x
      sleep 3
      xsway
      # zellij attach -c autologin
    '').outPath);

    systemd.services.systemd-udev-settle.enable = false; ## ????
    # mobile.boot.stage-1.ssh.enable = false;
    mobile.boot.stage-1.bootConfig.log.level = "DEBUG";
    mobile.boot.stage-1.crashToBootloader = true;
    #mobile.boot.stage-1.fbterm.enable = false;         #??????????

    services.blueman.enable = false;
    hardware.bluetooth.enable = lib.mkForce false;
  };
}