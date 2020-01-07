#!/usr/bin/env bash
set -euo pipefail
set -x

declare -A timezones=(
  ["SEA"]=":US/Pacific"
  ["BER"]=":Europe/Berlin"
)

result=""
for K in "${!timezones[@]}"; do
  time="$(env TZ="${timezones["$K"]}" date '+%H:%M:%S')"
  day="$(env TZ="${timezones["$K"]}" date '+%d')"
  result="${result}${K}[${day}]${time} "
done

result="${result%" "}"
printf "%s" "${result}"

