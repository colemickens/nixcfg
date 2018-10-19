#!/usr/bin/env bash
set -x
set -euo pipefail

unset NIX_PATH
unset NIXOS_CONFIG

closure="${1:-"../../default.nix"}"
nixcfg="/etc/nixcfg"

results="$("${nixcfg}/build.sh")"

installables=()
echo "${results}" | while read -r closure; do
  installables+=("${closure}")
done

"${nixcfg}/utils/azure/nix-copy.sh" "${installables[@]}"
"${nixcfg}/utils/azure/nix-sign-store.sh"
"${nixcfg}/utils/azure/upload-cache.sh"

