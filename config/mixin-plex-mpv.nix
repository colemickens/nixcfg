{ pkgs, ... }:

let 
  swaycfg = pkgs.writeText "swayconfig" ''
    exec ${pkgs.plex-mpv-shim}/bin/plex-mpv-shim
  '';
in
{
  ## TODO: this relies on getty autostart
  # and having a .bash_profile that
  # starts sway... and a swaycfg
  # that starts plex-mpv-shim
  # we can do better.

  config = {
    environment.systemPackages = with pkgs; [ plex-mpv-shim ];

    networking.firewall.allowedTCPPorts = [ 3000 ];
    networking.firewall.allowedUDPPorts = [ 32410 32412 32413 32414 ];

    sound.enable = true;
    hardware.pulseaudio.enable = true;

    #services.mingetty.autologinUser = "cole";
    #systemd.services.plex-mpv = {
    #  description = "plex-mpv";
    #  serviceConfig = {
    #    Type = "simple";
    #    ExecStart = "${pkgs.sway}/bin/sway -c ${swaycfg}";
    #    Restart = "always";
    #  };
    #  wantedBy = [ "default.target" ];
    #  bindsTo = [ "graphics-session-pre.target" ];
    #};
  };
}
