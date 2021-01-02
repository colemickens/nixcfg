{ config, pkgs, ... }:

{
  security.rtkit.enable = true; # ?

  nixpkgs.config.pulseaudio = true;
  #hardware.pulseaudio.enable = true; # we're trying pipewire
  hardware.pulseaudio.enable = pkgs.lib.mkForce false;

  environment.systemPackages = with pkgs; [
    wireplumber
    pavucontrol
    pavucontrol-qt
    qjackctl
  ];

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true; # ?
    pulse.enable = true;
    jack.enable = true;
  };
}
