{ config, pkgs, ... }:

{
  security.rtkit.enable = true; # ?

  nixpkgs.config.pulseaudio = true;
  #hardware.pulseaudio.enable = true; # we're trying pipewire

  environment.systemPackages = with pkgs; [
    #wireplumber
  ];

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true; # ?
    pulse.enable = true;
    jack.enable = true;
  };
}
