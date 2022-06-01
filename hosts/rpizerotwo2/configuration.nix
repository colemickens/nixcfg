{ pkgs, lib, modulesPath, inputs, config, ... }:

let
  hn = "rpizerotwo2";
  mbr_disk_id = "99999022";
in
{
  imports = [
    ../rpizerotwo1/configuration.nix
  ];

  config = {
    system.build.mbr_disk_id = lib.mkForce mbr_disk_id;
    networking.hostName = lib.mkForce hn;
    boot.kernelPackages = lib.mkOverride 100 pkgs.linuxPackages_latest;
    boot.kernelParams = [
      "snd_bcm2835.enable_hdmi=1"
      "snd_bcm2835.enable_headphones=0"
      # "snd_bcm2835.enable_compat_alsa=0"
    ];
    boot.blacklistedKernelModules = [ "snd_bcm2835" ]; # ??
  };
}
