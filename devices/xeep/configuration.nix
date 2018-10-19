{ config, lib, pkgs, ... }:

let
  patches = (import ./patches.nix { inherit (pkgs) fetchpatch; });
  cfg = config.xeep;
in {
  imports = [
    ./hardware-configuration.nix

    # Each device must have one `profile-X.nix` and one or more `user-X.nix`
    ../../modules/profile-gui.nix
    ../../modules/user-cole.nix

    # Each device may include `mixin-X.nix` that may not be part of the profile
  ];

  # TODO: remove when we move to a 4.20-rc1 with the magic trackpad patches
  # TODO: then we can follow up on the libinput bug
  # TODO: also, for now, let's use the "bad" v3 patch that works without the libinput quirk
  options = { xeep.kernelPatches = lib.mkOption { default = [ patches.trackpadPatchV3 ]; }; };

  config = {
    # TODO: reorganize this?
    # vaapi stuff
    environment.systemPackages = with pkgs; [ libva libva-full libva-utils ];

    system.stateVersion = "18.09";

    userOptions.cole = { tmuxColor="magenta"; bashColor="1;35"; };

    time.timeZone = "America/Los_Angeles";

    # hidpi stuff
    boot.earlyVconsoleSetup = true;
    fonts.fonts = with pkgs; [ terminus_font ];
    i18n.consolePackages = [ pkgs.terminus_font ];
    i18n.consoleFont = "ter-v32n";

    # ignore psmouse, errors on Dell HW
    boot.blacklistedKernelModules = [ "psmouse" ];

    # newer kernel
    boot.kernelPackages = pkgs.linuxPackages_testing;
    boot.kernelPatches = cfg.kernelPatches;
    boot.extraModulePackages = [ config.boot.kernelPackages.wireguard ];

    services.fwupd.enable = true;

    nix.nixPath = [ "/etc/nixos" "nixpkgs=/etc/nixpkgs" "nixos-config=/etc/nixos/configuration.nix" ];

    hardware = {
      bluetooth.enable = true;
      opengl.extraPackages = with pkgs; [ vaapiIntel ];
      pulseaudio.package = pkgs.pulseaudioFull;
      enableRedistributableFirmware = true;
      cpu.intel.updateMicrocode = true;
      #enableAllFirmware = true;
      u2f.enable = true;
    };

    powerManagement.enable = true;
    services.tlp.enable = true;

    networking = {
      hostName = "xeep";
      firewall.allowedTCPPorts = [ 3000 ];
      networkmanager.enable = true;
    };
  };
}

