#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
b="$(mktemp)"
trap "rm ${b}" EXIT

cp "${DIR}/bootstrap.in.nix" "${b}"

awk -i inplace -v r="$(gopass show "colemickens/packet.net" | grep apikey | cut -d' ' -f2)" \
  '{gsub(/PACKETAPITOKEN/,r)}1' "${b}"

awk -i inplace -v r="$(gopass show "colemickens/packet.net" | grep default_project_id | cut -d' ' -f2)" \
  '{gsub(/PACKETPROJECTID/,r)}1' "${b}"

awk -i inplace -v r="$(cat ~/.config/cachix/cachix.dhall)" \
  '{gsub(/CACHIXDHALL/,r)}1' "${b}"

awk -i inplace -v r="$(cat "${DIR}/../../modules/user-cole.nix" | head -n-2 | tail -n+3)" \
  '{gsub(/USERCONFIG/,r)}1' "${b}"

cat "${b}"
