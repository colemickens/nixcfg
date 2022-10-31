{ pkgs, config, ... }:

{
  config = {
    hardware.video.hidpi.enable = true;

    # services = {
    #   kmscon.extraConfig = ''
    #     font-size=40
    #   '';
    # };
  };
}
