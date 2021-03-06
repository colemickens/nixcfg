{ config, pkgs, ... }:

{
  config = {

    boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback  ];

    environment.systemPackages = with pkgs; [
      v4l-utils

      (pkgs.writeScript "obs-v4l2loopback-setup" ''
        set -x
        sudo modprobe v4l2loopback devices=1 video_nr=13 card_label="''${CAMERA_NAME:-"OBS Virtual Camera"}" exclusive_caps=1
      '')
    ];

    home-manager.users.cole = { pkgs, ... }: {
      programs.obs-studio = {
        enable = true;

        plugins = with pkgs; [
          obs-wlrobs
        ];
      };
    };
  };
}
