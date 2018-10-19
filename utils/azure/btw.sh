#!/usr/bin/env bash
set -x
set -euo pipefail

unset NIX_PATH
unset NIXOS_CONFIG

closure="${1:-"../../default.nix"}"
nixcfg="/etc/nixcfg"

results="$("${nixcfg}/utils/azure/nix-build.sh" "${closure}")"
echo "${results}" | while read -r closure; do
  "${nixcfg}/utils/azure/cache-closure.sh" "${closure}"
done

# for good measure, always take a copy of the current system too
"${nixcfg}/utils/azure/cache-closure.sh" "/run/current-system"

"${nixcfg}/utils/azure/upload-cache.sh"

