#!/usr/bin/env bash
set -euo pipefail
set -x

toplevel="$(nix-build -A raspberry default.nix)"

nix copy --to "ssh://cole@192.168.1.2" "${toplevel}"

ssh "cole@192.168.1.2" "sudo nix-env --set --profile '/nix/var/nix/profiles/system' '${toplevel}'"
ssh "cole@192.168.1.2" "sudo '${toplevel}/bin/switch-to-configuration' switch"
