#!/usr/bin/env bash
set -x
set -euo pipefail

unset NIX_PATH
unset NIXOS_CONFIG

closure="${1:-"../../default.nix"}"
nixcfg="/etc/nixcfg"

pushd "${nixcfg}"
results="$(./build.sh)"
popd

echo "${results}" | while read -r closure; do
  "${nixcfg}/utils/azure/cache-closure.sh" "${closure}"
done

"${nixcfg}/utils/azure/cache-closure.sh" "/run/current-system"

"${nixcfg}/utils/azure/upload-cache.sh"

