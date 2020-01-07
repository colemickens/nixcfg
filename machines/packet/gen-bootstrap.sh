#!/usr/bin/env bash
set -euo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
b="$(mktemp)"
trap "rm ${b}" EXIT

if [[ "${1:-""}" == "" ]]; then
  exit -1
fi

cp "${DIR}/bootstrap.in.nix" "${b}"

awk -i inplace -v r="$(gopass show "colemickens/packet.net" | grep apikey | cut -d' ' -f2)" \
  '{gsub(/PACKETAPITOKEN/,r)}1' "${b}"

awk -i inplace -v r="$(gopass show "colemickens/packet.net" | grep default_project_id | cut -d' ' -f2)" \
  '{gsub(/PACKETPROJECTID/,r)}1' "${b}"

awk -i inplace -v r="$(cat ~/.config/cachix/cachix.dhall)" \
  '{gsub(/CACHIXDHALL/,r)}1' "${b}"

echo "BOOTSTRAP SCRIPT CANT CONTAIN AMPERSAND" &>/dev/stderr

#awk -i inplace -v r="$(cat "${DIR}/../../modules/user-cole.nix" | head -n-2 | tail -n+3)" \
awk -i inplace -v r="$(cat "${DIR}/../../modules/user-cole.nix")" \
  '{gsub(/USERCONFIG/,r)}1' "${b}"

awk -i inplace -v r="$(cat "${1}")" \
  '{gsub(/BOOTSTRAP/,r)}1' "${b}"

cat "${b}"
