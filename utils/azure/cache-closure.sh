#!/usr/bin/env bash

set -x
set -euo pipefail

target="${1:-"/run/current-system"}"
store="${2:-"${HOME}/.nixcache"}"
key="/etc/nixos/secrets/nixcache.cluster.lol-1-secret"

mkdir -p "${store}/nar"

nix copy --to "file://${store}" "${target}"
nix sign-paths --store "file://${store}" -k "${key}" "${target}" -r

