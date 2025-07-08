{ pkgs, ... }:

{
  security.rtkit.enable = true; # ????
  nixpkgs.config.pulseaudio = true; # ????

  environment.systemPackages = with pkgs; [
    alsa-utils # ignore for now cross-compile problem
    pipewire
    pulseaudio
    pulsemixer
    wiremix
  ];

  programs.dconf.enable = true;

  systemd.user.services.pipewire-pulse.path = [ pkgs.pulseaudio ];

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true; # ?
    pulse.enable = true;
    jack.enable = true;
  };
}
