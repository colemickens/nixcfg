#!/usr/bin/env nix-shell
#! nix-shell -i bash -p bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
b="$(mktemp)"
trap "rm ${b}" EXIT

cp "${DIR}/bootstrap.in.nix" "${b}"

awk -i inplace -v r="$(cat ~/.secrets/packet-apitoken)" \
  '{gsub(/PACKETAPITOKEN/,r)}1' "${b}"

awk -i inplace -v r="$(cat ~/.secrets/packet-projectid)" \
  '{gsub(/PACKETPROJECTID/,r)}1' "${b}"

awk -i inplace -v r="$(cat ~/.config/cachix/cachix.dhall)" \
  '{gsub(/CACHIXDHALL/,r)}1' "${b}"

cat "${b}"
