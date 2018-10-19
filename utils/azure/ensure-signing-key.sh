#!/usr/bin/env bash
set -x
set -euio pipefail

keyid="nixcache.cluster.lol-1"
sec="/etc/nixos/secrets/${keyid}-secret"
pub="/etc/nixos/secrets/${keyid}-public"

count=0
[[ -f "${sec}" ]] && count=$(( $count + 1 ))
[[ -f "${pub}" ]] && count=$(( $count + 1 ))

if [[ $count -gt 0 && $count -lt 2 ]]; then
  echo "invalid state, one exists, but not both"
  exit -1
elif [[ $count -eq 2 ]]; then
  echo "nothing to do, pub/sec parts exist: "
  echo "- signing key: ${sec}"
  echo "- signature:   ${pub}"
  exit 0
fi 

# we made it here, we need to generate

nix-store --generate-binary-cache-key "${keyid}" "${sec}" "${pub}"
