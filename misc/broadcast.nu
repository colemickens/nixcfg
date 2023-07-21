#!/usr/bin/env nu

let at = "testgstreamer"
# let we = $"https://b.siobud.com/api/whip"
let we = $"http://localhost:8080/api/whip"
# let we = $"https://b.siobud.com/api/whip/($at)"

print -e $"whip-endpoint=($we)"

$env.GST_DEBUG = 2

(gst-launch-1.0 -v
# videotestsrc pattern=snow
v4l2src
  ! videoconvert
  ! x264enc tune="zerolatency"
  ! rtph264pay
  ! application/x-rtp,media=video,encoding-name=H264,payload=97,clock-rate=90000
  ! whip0.sink_0
audiotestsrc wave=5
  ! audioconvert
  ! opusenc
  ! rtpopuspay
  ! application/x-rtp,media=audio,encoding-name=OPUS,payload=96,clock-rate=48000,encoding-params=(string)2
  ! whip0.sink_1
whipsink
  name=whip0
  use-link-headers=true
  $"auth-token=($at)"
  $"whip-endpoint=($we)"
)

