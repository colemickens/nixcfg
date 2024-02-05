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
    environment.systemPackages = [
      # cat $(readlink -f $(which stream1))"
      pkgs.libcamera
      (pkgs.writeShellScriptBin "stream1" ''
        set -x
        set -euo pipefail

        export GST_PLUGIN_SYSTEM_PATH_1_0="${""
          + ":" + "${pkgs.gst_all_1.gst-plugins-base}/lib/gstreamer-1.0"
          + ":" + "${pkgs.gst_all_1.gst-plugins-good}/lib/gstreamer-1.0"
          + ":" + "${pkgs.gst_all_1.gst-plugins-bad}/lib/gstreamer-1.0"
          + ":" + "${pkgs.gst_all_1.gst-plugins-ugly}/lib/gstreamer-1.0"
          + ":" + "${pkgs.gst_all_1.gst-plugins-rs}/lib/gstreamer-1.0"
          + ":" + "${pkgs.gst_all_1.gst-libav}/lib/gstreamer-1.0"
          + ":" + "${pkgs.gst_all_1.gst-vaapi}/lib/gstreamer-1.0"
        }"

        whip_endpoint=$1
        auth_token=$2
        v="''${3:-"/dev/video1"}"
        srcelem=(v4l2src "device=$v")
        # srcelem=(libcamerasrc "camera-name=$v")
        audioelem=(audiotestsrc wave=8)

          # ! decodebin  name=decoder ! queue ! video/x-raw \

        ${pkgs.gst_all_1.gstreamer}/bin/gst-launch-1.0 -v \
          ''${srcelem[@]} \
          ! videoconvert ! queue ! vp8enc deadline=1 \
          ! rtpvp8pay ! queue \
          ! whipclientsink name=ws use-link-headers=true \
          ! auth-token="''${auth_token}" \
            whip-endpoint="''${whip_endpoint}" \
            decoder. \
            ! queue ! audio/x-raw ! opusenc ! rtpopuspay ! queue ! ws.


        exit 0
          ''${srcelem[@]} \
            ! videoconvert \
            ! x264enc tune="zerolatency" \
            ! rtpvp8pay \
            ! application/x-rtp,media=video,encoding-name=H264,payload=97,clock-rate=90000 \
            ! whip0.sink_0 \
          ''${audioelem[@]} \
            ! audioconvert \
            ! opusenc \
            ! rtpopuspay \
            ! "application/x-rtp,media=audio,encoding-name=OPUS,payload=96,clock-rate=48000,encoding-params=(string)2" \
            ! whip0.sink_1 \
          whipsink \
            name=whip0 \
            use-link-headers=true \
            "whip-endpoint=''${whip_endpoint}" \
            "auth-token=''${auth_token}"
      '')
    ];
  };
}
