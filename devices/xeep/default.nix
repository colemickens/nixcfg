{ config, lib, pkgs, ... }:

let
  # TODO: fix the Url/hash for v3 patch
  # compare adn contrast, v4 seems a lot worse
  trackpadPatchV3 = {
    name = "apple-magic-trackpad2-driver";
    patch = pkgs.fetchpatch {
      name = "trackpad.patch";
      url = "https://lkml.org/lkml/diff/2018/9/21/38/1";
      sha256 = "018wyjvw4wz79by38b1r6bkbl34p6686r66hg7g7vc0v24jkcafn";
    };
  };
  trackpadPatchV4 = {
    name = "apple-magic-trackpad2-driver";
    patch = pkgs.fetchpatch {
      name = "trackpad.patch";
      url = "https://lkml.org/lkml/diff/2018/10/3/111/1";
      sha256 = "10f555falis1n8x7y6sfp0v2la1nrfyry82bwmn7bpjni66jb6gf";
    };
  };
in {
  imports = [
    ../../profiles/gui
    ./hardware-configuration.nix
  ];

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
  boot.kernelPatches = [ trackpadPatchV3 ];
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
}

