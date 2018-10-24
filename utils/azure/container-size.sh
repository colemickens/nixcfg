#!/usr/bin/env bash

container="${1:-"nixcache"}"
$(az storage blob list --container "${container}" \
  | jq -r '.[].properties.contentLength' \
  | awk '{s+=$1} END {print s}' -)

