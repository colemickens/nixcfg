#!/usr/bin/env bash

# TODO: should we pre-emptively re-sign the whole store?
# (that would help in my scenario where I have pkgs cached with the old sig
# and want to be able to re-sign with the new key. if it's already been re-cached in
# our cache dir, and it's not explicitly re-referenced here, it could wind up still being an old
# package in the store that we care about and want valid in the cache, so we might want to resign
# everything in case we want it later)

set -x
set -euo pipefail

target="${1:-"/run/current-system"}"
store="${2:-"${HOME}/.nixcache"}"
key="/etc/nixos/secrets/nixcache.cluster.lol-1-secret"

mkdir -p "${store}/nar"

nix copy --to "file://${store}" "${target}"
nix sign-paths --store "file://${store}" -k "${key}" "${target}" -r

