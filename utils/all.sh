#!/usr/bin/env bash
root="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )/.."
set -euo pipefail
set -x

# NOTE: EVERYTHING should be buildable without
# any implicit vars. We must always specify the
# nixpkgs we are using! This includes in our overlays.
unset NIX_PATH
unset NIXOS_CONFIG

buildables=("${root}/default.nix")

if [[ -d /etc/nix-overlay-sway ]]; then
  buildables+=("/etc/nix-overlay-sway/build.nix")
fi

results="$(nix-build "${buildables[@]}")"
readarray -t installables <<< "$(echo "${results}")"
"${root}/utils/azure/nix-copy.sh" "${installables[@]}"

"${root}/utils/azure/nix-sign-store.sh"
"${root}/utils/azure/upload-cache.sh"

