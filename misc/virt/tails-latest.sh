#!/usr/bin/env bash

set -euo pipefail
set -x

export TAILS_SEED_TIME=99999999
trap "echo \$TAILS_VERSION" EXIT
TAILS_VERSION="0"
#export TAILS_SEED_TIME=0

# fetch upstream info
index="https://tails.boum.org/install/v2/Tails/amd64/stable/latest.json"
xh "${index}" > /tmp/tails.json
ver="$(</tmp/tails.json jq -r ".installations[0].version")"
TAILS_VERSION="${ver}"

# check if we exist
f="tails-amd64-${ver}"
dest="${HOME}/.cache/tails/${ver}"
if [[ ! -d "${dest}" ]]; then
  mkdir -p "${dest}"


  aria2c --dir="${dest}" --seed-time="${TAILS_SEED_TIME}" -Z \
    "https://tails.boum.org/torrents/files/${f}.iso.torrent" \
    "https://tails.boum.org/torrents/files/${f}.img.torrent" > /dev/stderr
fi

ln -sf "${dest}/${f}-iso/${f}.iso" "${HOME}/.cache/tails/tails.iso"
ln -sf "${dest}/${f}-img/${f}.img" "${HOME}/.cache/tails/tails.img"

ls -al "${HOME}/.cache/tails"
