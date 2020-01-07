#!/usr/bin/env bash

set -euo pipefail
set -x

if [[ "${1}" == "twitch" ]]; then
  URL="$(gopass show colemickens/twitch.tv | grep stream_url | cut -d' ' -f2-)"
elif [[ "${1}" == "youtube" ]]; then
  URL="$(gopass show websites/youtube.com | grep stream_url | cut -d' ' -f2-)"
elif [[ "${1}" == "loopback" ]]; then
  true # do v4l2loopback stuffs here
fi

CODEC="libx264"
CODEC="h264_vaapi"

OUTPUT="${OUTPUT:-"DP-1"}"

wf-recorder \
  -c "${CODEC}" \
  -o "${OUTPUT}" \
  -d "/dev/dri/renderD128" \
  -f "${URL}"
