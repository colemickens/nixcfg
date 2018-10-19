#!/usr/bin/env bash
set -x
set -euo pipefail

store="${HOME}/.nixcache"
key="/etc/nixos/secrets/nixcache.cluster.lol-1-secret"

nix sign-paths --store "file://${store}" -k "${key}" --all

