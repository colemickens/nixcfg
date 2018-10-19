#!/usr/bin/env bash
set -x
set -euo pipefail

unset NIX_PATH
unset NIXOS_CONFIG

closure="${1:-"../../default.nix"}"
nixcfg="/etc/nixcfg"

readarray -t installables <<< "$("${nixcfg}/build.sh")"

"${nixcfg}/utils/azure/nix-copy.sh" "${installables[@]}"
"${nixcfg}/utils/azure/nix-sign-store.sh"
"${nixcfg}/utils/azure/upload-cache.sh"

