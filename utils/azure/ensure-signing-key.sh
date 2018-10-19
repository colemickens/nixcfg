#!/usr/bin/env bash

# TODO: generate the signing key if we don't have it

# TODO: add warning since we should already made the real one available somehow

keyid="nixcache.cluster.lol-1"
sec="/etc/nixos/secrets/${keyid}-secret"
pub="/etc/nixos/secrets/${keyid}-public"

count=0
[[ -f "${sec}" ]] && count=$(( $count + 1 ))
[[ -f "${pub}" ]] && count=$(( $count + 1 ))

if [[ $count > 0 && $count < 2]]; then
  echo "invalid state, one exists, but not both"
  exit -1
elif [[ $count == 2]]; then
  echo "nothing to do, pub/sec parts exist: "
  echo "- signing key: ${sec}"
  echo "- signature:   ${pub}"
  exit 0
fi 

# we made it here, we need to generate

nix-store --generate-binary-cache "${keyid}" "${sec}" "${pub}"
