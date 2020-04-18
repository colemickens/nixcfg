#!/usr/bin/env bash
set -euo pipefail
set -x

alloutputs="$(swaymsg -t get_outputs)"

outputnames="$(printf "${alloutputs}" | jq -r '.[] | select(.active == true).name')"

result=""
while read -r out; do
  scale="$(swaymsg -t get_outputs | jq ".[] | select(.name==\"${out}\").scale")"
  printf -v scale "%.01f" "${scale}"
  result="${result}${out}(${scale}) "
done < <(echo "${outputnames}")

printf "%s" "${result} "

