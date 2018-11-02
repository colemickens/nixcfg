#!/usr/bin/env bash
set -euo pipefail
set -x

export AZURE_STORAGE_CONNECTION_STRING="${AZURE_STORAGE_CONNECTION_STRING:-"$(cat /etc/nixos/secrets/kixstorage-secret)"}"

container="${1:-"nixcache"}"
az storage blob list --container "${container}" \
  | jq -r '.[].properties.contentLength' \
  | awk '{s+=$1} END {print s}' -

