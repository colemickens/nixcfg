{ pkgs, lib, config, inputs, ... }:

{
  config = {
    networking.wireless.iwd.enable = true;

    environment.sessionVariables = {
      GST_PLUGIN_SYSTEM_PATH = ""
        + ":" + "${pkgs.gst_all_1.gst-plugins-base}/lib/gstreamer-1.0"
        + ":" + "${pkgs.gst_all_1.gst-plugins-good}/lib/gstreamer-1.0"
        + ":" + "${pkgs.gst_all_1.gst-plugins-bad}/lib/gstreamer-1.0"
        + ":" + "${pkgs.gst_all_1.gst-plugins-ugly}/lib/gstreamer-1.0"
        + ":" + "${pkgs.gst_all_1.gst-libav}/lib/gstreamer-1.0"
      ;
    };

    # include gstreamer
    environment.systemPackages = with pkgs; [
      # gst-launch-1
      # extra plugins, etc
      gst_all_1.gstreamer
      # gst_all_1.gst-plugins-base
      # gst_all_1.gst-plugins-good
      # gst_all_1.gst-plugins-bad
      # gst_all_1.gst-plugins-ugly
      # gst_all_1.gst-libav
    ];
  };
}
