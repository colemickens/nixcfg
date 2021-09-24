#!/usr/bin/env bash

set -euo pipefail
set -x

export TAILS_SEED_TIME=99999999
#export TAILS_SEED_TIME=0

# fetch upstream info
index="https://tails.boum.org/install/v2/Tails/amd64/stable/latest.json"
curl --silent "${index}" > /tmp/tails.json 
ver="$(</tmp/tails.json jq -r ".installations[0].version")"

# check if we exist
dest="${HOME}/.cache/sliat-${ver}"
if [[ -d "${dest}" ]]; then exit 0; fi

# temp workdir
OUTDIR="$(mktemp -d "/tmp/ktails.XXXXXX")";
trap "rm -rf ${OUTDIR}" EXIT

aria2c --dir="${OUTDIR}" --seed-time="${TAILS_SEED_TIME}" -Z \
  "https://tails.boum.org/torrents/files/tails-amd64-${ver}.iso.torrent" \
  "https://tails.boum.org/torrents/files/tails-amd64-${ver}.img.torrent"

mv "${OUTDIR}" "${dest}"
