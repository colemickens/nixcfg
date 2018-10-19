#!/usr/bin/env bash
set -x
set -euo pipefail

store="${HOME}/.nixcache"
mkdir -p "${store}/nar"

nix copy --to "file://${store}" "${@}"

