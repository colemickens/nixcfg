{ pkgs, lib, config, inputs, ... }:

{
  config = {
    networking.wireless.iwd.enable = true;

    # include gstreamer
    environment.systemPackages = with pkgs; [
      # gst-launch-1
      # extra plugins, etc
      gst_all_1.gstreamer
      gst_all_1.gst-plugins-base
      gst_all_1.gst-plugins-good
      gst_all_1.gst-plugins-bad
      gst_all_1.gst-plugins-ugly
      gst_all_1.gst-libav
    ];
  };
}
