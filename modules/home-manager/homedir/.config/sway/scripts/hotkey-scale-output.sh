#!/usr/bin/env bash
set -euo pipefail

delta=$1; shift

scale="$(swaymsg -t get_outputs | jq '.[] | select(.focused == true) | .scale')"
printf -v scale "%.1f" "${scale}"
scale="$(echo "${scale} ${delta}" | bc)"

swaymsg output "-" scale "${scale}"

