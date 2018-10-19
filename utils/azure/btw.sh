#!/usr/bin/env bash
set -x
set -euo pipefail

unset NIX_PATH
unset NIXOS_CONFIG

f="${1:-"../../default.nix"}"

results="$("${nixcfg/utils/azure/nix-build-with-cache.sh" "${closure}")"
echo "${results}" | while read -r closure; do
  "${nixcfg}/utils/nix/cache-closure.sh" "${closure}"
done

# for good measure, always take a copy of the current system too
"${nixcfg}/utils/nix/cache-closure.sh" "/run/current-system"

"${nixcfg}/utils/azure/upload-cache.sh"

