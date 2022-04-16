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
dest="${HOME}/.cache/sliat-${ver}"
# if [[ -d "${dest}" ]]; then exit 0; fi

# # temp workdir
OUTDIR="/tmp/sliat"
# trap "rm -rf ${OUTDIR}" EXIT

f="tails-amd64-${ver}"

aria2c --dir="${OUTDIR}" --seed-time="${TAILS_SEED_TIME}" -Z \
  "https://tails.boum.org/torrents/files/${f}.iso.torrent" \
  "https://tails.boum.org/torrents/files/${f}.img.torrent" > /dev/stderr

mv "${OUTDIR}/${f}-iso/${f}.iso" "${HOME}/.cache/sliat.iso"
mv "${OUTDIR}/${f}-img/${f}.img" "${HOME}/.cache/sliat.img"

