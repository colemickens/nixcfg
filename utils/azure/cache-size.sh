#!/usr/bin/env bash

az storage blob list --container nixcache \
  | jq -r '.[].properties.contentLength' \
  | awk '{s+=$1} END {print s}' -
